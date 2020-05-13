#include <iostream>
#include <fstream>
#include <sstream>

int main() {
    std::ifstream input("for_hackers", std::ios::binary);
    std::ofstream output("for_hackers.crack", std::ios::binary);
    std::ostringstream ss;
    ss << input.rdbuf();
    std::string s = ss.str();
    int offset = 199;
    if (s[offset] == 0x48 && static_cast<unsigned char>(s[offset + 1]) == 0xbe) {
        char* str = [0xba, 0x20, 0x00, 0x00, 0x00]
        s[offset + 2] = 0x41;
        for (int i = 0; i < 5; i++) {
            s[offset + 20 + i] = str[i];
        }
        output << s;
     } else {
         std::cout << "Bad input file " << std::hex << (unsigned int8_t) s[offset] << std::hex <<  (unsigned int8_t) s[offset + 1] << std::endl;
         std::cout << "Expected " << std::hex << (unsigned int8_t) 0x48 << std::hex <<  (unsigned int8_t) 0xbe << std::endl;
     }
}