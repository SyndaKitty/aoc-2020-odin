package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:container"
import "core:time"
import "core:sys/windows"


// Custom libraries
import "permute"
import "parse"


// Common functions -----------------------------------------------//
sort_two :: proc(a: int, b: int) -> (int, int)
{
    return min(a,b), max(a,b);
}


sort :: proc
{
    sort_two
};


hash_2D :: proc(x: int, y: int) -> i64
{
    mask_32 :: 1 << 32 - 1;

    x_32 := i64(x & mask_32);
    y_32 := i64(y & mask_32);

    hash : i64 = y_32 << 32 + x_32;

    return hash;
}


xor :: inline proc(a: bool, b: bool) -> bool
{
    return (a && !b) || (b && !a);
}


print_binary :: proc(num: int, digits: uint)
{
    bit_mask : int = 1 << digits-1;
    i : uint = digits-1;
    for
    {
        digit := (num & bit_mask) >> i;
        fmt.print(digit);
        bit_mask = bit_mask >> 1;
        if i == 0 
        {
            fmt.println();
            return;
        }
        i = i - 1;
    }
}


is_digit :: proc(char: rune) -> bool
{
    return (char >= '0' && char <= '9') || char == '-';
}


is_num :: proc(char: rune) -> bool
{
    return is_digit(char) || char == '-' || char == '.';
}


// Puzzles --------------------------------------------------------//
day_one :: proc(input: string) 
{
    using parse;
    parse_info := make_parse_info(input);
    parse_info.search = {TokenType.Word, TokenType.Number};

    ints := make([dynamic]int);

    for 
    {
        token,ok := parse_next(&parse_info);
        if !ok do break;
        
        // token.data;
        append(&ints, token.number);
    }

    for a,i in ints
    {
        for b,j in ints
        {
            for c,k in ints
            {
                if i != j && j != k && i != k && a + b + c == 2020
                {
                    fmt.println(a * b * c);
                    return;
                }
            }
        }
    }
}

day_two :: proc(input: string)
{
    using parse;
    parse_info := make_parse_info(input);
    parse_info.search = {TokenType.Word, TokenType.Number};

    valid := 0;

    for has_next(&parse_info)
    {
        // 4-9 m: xvrwfmkmmmc
        low := next_number(&parse_info);
        next_rune(&parse_info);
        high := next_number(&parse_info);
        letter := rune(next_word(&parse_info)[0]);
        word := next_word(&parse_info);

        // count := 0;
        // for c in word
        // {
        //     if c == rune(letter)
        //     {
        //         count += 1;
        //     }
        // }
        // fmt.println(word, "has", count, letter, "against", low, "-", high, count >= low && count <= high);
        // if count >= low && count <= high
        // {
        //     valid += 1;
        // }

        left := word[low-1] == u8(letter);
        right := word[high-1] == u8(letter);
        if left ~ right do valid += 1;
    }
    

    fmt.println(valid);
}


day_three :: proc(input: string)
{
    using parse;

    parse_info := make_parse_info(input);
    parse_info.search = {TokenType.Word, TokenType.Number};

    for has_next(&parse_info)
    {
        next_number(&parse_info);
        next_rune(&parse_info);
        next_word(&parse_info);
        

    }

    for c in input
    {
        switch c
        {
            case ' ':
                
        }
    }
}


// Driver ---------------------------------------------------------//
read_input_file :: proc(index: int) -> (string, bool) 
{
    file_name: string;
    {
        inputs_prefix  :: "..\\inputs\\";
        inputs_postfix :: ".txt";
        
        builder := strings.make_builder();
        strings.write_string(&builder, inputs_prefix);
        
        // Prepend 0 for days 1-9
        if index < 10 do strings.write_int(&builder, 0);
        
        strings.write_int(&builder, index);
        strings.write_string(&builder, inputs_postfix);

        file_name = strings.to_string(builder);
    }
    
    data, success := os.read_entire_file(file_name);
    if !success do return "", success;
    return string(data), success;
}


read_user_input :: proc(data: []byte, length: int) -> bool 
{
    index := 0;
    for index < length
    {
        _, input_err := os.read(os.stdin, data[index:index+1]);
        if input_err != 0
        {
            return true;
        }

        // Line feed
        if data[index] == 10 
        {
            return false;
        }
        index = index + 1;
    }

    return false;
}


main :: proc() 
{
    input, read_success := read_input_file(2);
    if !read_success
    {
        fmt.println("Error occurred while reading input file");
    }
    else 
    {
        day_two(input);
    }

    // user_input := make([]byte, 4);

    // for 
    // {
    //     // Get user input
    //     fmt.print("Enter day number of puzzle to solve: ");
    //     input_err := read_user_input(user_input, 4);

    //     if input_err
    //     {
    //         fmt.println("Error reading input");
    //     }

    //     // Check for attempted exit
    //     lower_user_input := strings.to_lower(string(user_input));
    //     if lower_user_input == "stop" || lower_user_input == "exit"
    //     {
    //         return;
    //     }
    //     delete(lower_user_input);

    //     day_number, ok := strconv.parse_int(string(user_input));
    //     if !ok 
    //     {
    //         fmt.println("Please enter a valid number day");
    //         continue;
    //     }

    //     input, read_success := read_input_file(day_number);
    //     if !read_success
    //     {
    //         fmt.println("Error occurred while reading input file");
    //         continue;
    //     }

    //     switch (day_number)
    //     {
    //         case 1:
    //             day_one(input);
    //         // case 2:
    //         //     day_two(input);
    //         // case 3:
    //         //     day_three(input);
    //         // case 4: 
    //         //     day_four(input);
    //         // case 5:
    //         //     day_five(input);
    //         // case 6:
    //         //     day_six(input);
    //         // case 7:
    //         //     day_seven(input);
    //         // case 8:
    //         //     day_eight(input);
    //         // case 9:
    //         //     day_nine(input);
    //         // case 10:
    //         //     day_ten(input);
    //         // case 11:
    //         //     day_eleven(input);
    //         // case 12:
    //         //     day_twelve(input);
    //         // case 13:
    //         //     day_thirteen(input);
    //         // case 14:
    //         //     day_fourteen(input);
    //         // case 15:
    //         //     day_fifteen(input);
    //         // case 16:
    //         //     day_sixteen(input);
    //         // case 17:
    //         //     day_seventeen(input);
    //         // case 18:
    //         //     day_eighteen(input);
    //         // case 19:
    //         //     day_nineteen(input);
    //         // case 20:
    //         //     day_twenty(input);
    //         // case 21:
    //         //     day_twenty_one(input);
    //         // case 22:
    //         //     day_twenty_two(input);
    //         // case 23:
    //         //     day_twenty_three(input);
    //         // case 24:
    //         //     day_twenty_four(input);
    //         // case 25:
    //         //     day_twenty_five(input);
    //         case 1..25:
    //             fmt.println("Day not implemented");
    //         case:
    //             fmt.println("Please enter a valid number day");
    //     }

    //     delete(input);
    // }
}