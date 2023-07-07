
include(CMakePrintHelpers)

if(NOT ${CMAKE_ARGC} EQUAL 4)
    message(FATAL_ERROR "One parameter is required: ftoba_cpp_path.")
endif()

set(ftoba_cpp_path ${CMAKE_ARGV3})

file(WRITE ${ftoba_cpp_path} [=[
#include <iostream>
#include <array>
#include <fstream>
#include <filesystem>
#include <cstdint>

void check_input_args(int argc)
{
    if (argc < 3)
    {
        std::cerr << "ERROR: arguments are missing. Please provide : input_file output_cpp_file." << std::endl;
        exit(EXIT_FAILURE);
    }
}

void check_input_file(const std::filesystem::path& input_file_path)
{
    if (!std::filesystem::exists(input_file_path))
    {
        std::cerr << "ERROR: Input file does not exist : " << input_file_path << "." << std::endl;
        exit(EXIT_FAILURE);
    }
}

void check_input_file(std::ifstream& input_file)
{
    if (!input_file)
    {
        std::cerr << "ERROR: Error while reading input file." << std::endl;
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char** argv)
{
    check_input_args(argc);

    std::filesystem::path input_file_path(argv[1]);
    std::filesystem::path output_cpp_file_path(argv[2]);
    check_input_file(input_file_path);

    std::ifstream input_file(input_file_path.string(), std::ios::binary|std::ios::ate);
    std::size_t input_file_size = input_file.tellg();
    input_file.seekg(0, std::ios::beg);
    std::ofstream output_cpp_file(output_cpp_file_path.string(), std::ios::binary|std::ios::app);
    output_cpp_file << '{';

    constexpr std::size_t buffer_size = 1024;
    std::array<uint8_t, buffer_size> bytes;

    for (;;)
    {
        std::size_t byte_count = std::min<std::size_t>(bytes.size(), input_file_size);
        input_file.read(reinterpret_cast<char*>(bytes.data()), byte_count);
        check_input_file(input_file);
        input_file_size -= byte_count;

        if (input_file_size > 0)
        {
            for (auto& byte : bytes)
                output_cpp_file << static_cast<uint16_t>(byte) << ',';
        }
        else
        {
            auto iter = bytes.begin();
            auto last_iter = bytes.begin() + byte_count - 1;
            for (; iter != last_iter; ++iter)
                output_cpp_file << static_cast<uint16_t>(*iter) << ',';
            output_cpp_file << static_cast<uint16_t>(*last_iter);
            break;
        }
    }

    output_cpp_file << "};" << std::endl;

    return EXIT_SUCCESS;
}
]=])
