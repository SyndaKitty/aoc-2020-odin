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

min :: proc(a: int, b: int) -> int
{
    if a < b do return a;
    return b;
}

max :: proc(a: int, b: int) -> int
{
    if a > b do return a;
    return b;
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


count_trees :: proc(trees: map[i64]bool, slope_x, slope_y, max_x, max_y: int) -> int
{
    x := slope_x;
    y := slope_y;
    tree_count := 0;

    for 
    {
        //fmt.println("Checking", x, y, trees[hash_2D(x, y)]);
        if trees[hash_2D(x, y)] do tree_count += 1;
        x += slope_x;
        x %= max_x;
        y += slope_y;
        if y >= max_y do break;
    }

    return tree_count;
}

day_three :: proc(input: string)
{
    using parse;

    parse_info := make_parse_info(input);
    parse_info.search = {TokenType.Word, TokenType.Number};

    trees := make(map[i64]bool);

    x := 0;
    y := 0;
    max_y := 0;
    max_x := 0;
    for c in input
    {
        switch c
        {
            case '.':
                trees[hash_2D(x,y)] = false;
                x += 1;
                max_x = x;
            case '#':
                trees[hash_2D(x,y)] = true;
                x += 1;
                max_x = x;
            case '\n':
                x = 0;
                y += 1;
                max_y = y+1;
        }
    }

    fmt.println(count_trees(trees, 1, 1, max_x, max_y));
    fmt.println(count_trees(trees, 3, 1, max_x, max_y));
    fmt.println(count_trees(trees, 5, 1, max_x, max_y));
    fmt.println(count_trees(trees, 7, 1, max_x, max_y));
    fmt.println(count_trees(trees, 1, 2, max_x, max_y));

    fmt.println(count_trees(trees, 1, 1, max_x, max_y)
    * count_trees(trees, 3, 1, max_x, max_y)
    * count_trees(trees, 5, 1, max_x, max_y)
    * count_trees(trees, 7, 1, max_x, max_y)
    * count_trees(trees, 1, 2, max_x, max_y));
}


// Day 4 redacted until I can clean it up.
// Yes it was that bad


front :: proc(in_min: int, in_max: int) -> (out_min: int, out_max: int)
{
    range := in_max - in_min;
    if range == 1
    {
        out_min = min(in_min, in_max);
        out_max = max(in_min, in_max);
    }
    out_min = in_min;
    out_max = in_max - range / 2 - 1;
    return;
}

back :: proc(in_min: int, in_max: int) -> (out_min: int, out_max: int)
{
    range := in_max - in_min;
    if range == 1
    {
        out_min = min(in_min, in_max);
        out_max = max(in_min, in_max);
    }
    out_min = in_min + range / 2 + 1;
    out_max = in_max;
    return;
}

seat_id :: proc(row: int, column: int) -> int
{
    return row * 8 + column;
}

day_five :: proc(input: string)
{
    using parse;
    parse_info := make_parse_info(input);
    parse_info.search = {TokenType.Word};

    max_seat := 0;
    min_seat := 999;
    seats := make(map[int]bool);

    for has_next(&parse_info)
    {
        line := next_word(&parse_info);
        min := 0;
        max := 127;
        for i in 0..6
        {
            if line[i] == u8('F')
            {
                min,max = front(min,max);
            }
            else
            {
                min,max = back(min,max);
            }
        }

        row := min;

        min = 0;
        max = 7;
        for i in 7..9
        {
            if line[i] == u8('L')
            {
                min,max = front(min,max);
            }
            else
            {
                min,max = back(min,max);
            }
        }

        col := min;
        id := seat_id(row, col);
        seats[id] = true;
        if id > max_seat
        {
            max_seat = id;
        }
        if id < min_seat
        {
            min_seat = id;
        }
    }

    for i in 32..913
    {
        if !(i in seats) do fmt.println(i);
    }


    fmt.println(min_seat, max_seat);
}


day_six :: proc(input: string)
{
    ints := make([dynamic]int);
    strings := make([dynamic]string);

    lines := strings.split(input, "\n");
    for line in lines
    {
        fmt.println(line);
    }

    // using parse;
    // parse_info := make_parse_info(input);
    // parse_info.search = {TokenType.Word,TokenType.Number};
    // for has_next(&parse_info)
    // {
    //     next_word(&parse_info);
    //     next_number(&parse_info);
    //     next_rune(&parse_info);
    // }

    // for c in input
    // {
    //     switch c 
    //     {
    //         case ' ': 

    //     }
    // }

    fmt.println();
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
    input, read_success := read_input_file(6);
    if !read_success
    {
        fmt.println("Error occurred while reading input file");
    }
    else 
    {
        day_six(input);
    }
}