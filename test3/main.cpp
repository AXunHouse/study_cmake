#include <iostream>
#include <json/json.h>
#include <string>

int main()
{
    Json::Value root;
    root["name"] = "wzx";
    root["age"] = 60;

    Json::StreamWriterBuilder writer;
    std::string json_str = Json::writeString(writer, root);

    std::cout << "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW" << std::endl;
    std::cout << json_str << std::endl;
    std::cout << "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW" << std::endl;


    return 0;
}