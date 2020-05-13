#include <iostream>
#include <fstream>
#include <sstream>

int main() {
    std::string input;
    std::cout << "Enter filename\n";
    std::cin >> input;
    std::ifstream f(input, std::ios::binary);
    std::stringstream ss;
    ss << f.rdbuf();
    std::string data = ss.str();
    if (data[3] != char(0xe8) || data[4] != char(0x38)) {
        std::cout << "Bad input file\n";
    } else {
        data[3] = 0xb9;
        data[4] = 0;
        data[5] = 0;
        std::cout << "Patched successful, output file patch.com\n";
        std::ofstream output("patch.com", std::ios::binary);
        output << data;
    }
    char c;
    std::cin >> c;
    return 0;
}