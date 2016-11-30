#include "rapidjson/document.h"
#include "rapidjson/writer.h"
#include "rapidjson/filereadstream.h"

#include <iostream>
#include <map>
#include <string>
#include <sstream>
#include <fstream>


using namespace rapidjson;

int main(int argc, char* argv[])
{

    if (argc!=3)
    {
        std::cerr << "ERROR: Two arguments needed (in_file, out_folder)" << std::endl;
        return 1;
    }

    std::string in_file(argv[1]);
    std::string out_folder(argv[2]);

    // Read file into document
    std::cout << "INFO: Reading the input file" << std::endl;
    FILE* fp = fopen(in_file.c_str(), "r");
    char readBuffer[65536];
    FileReadStream is(fp, readBuffer, sizeof(readBuffer));
    Document d;
    d.ParseStream(is);
    std::cout << "      Done" << std::endl;

    // Prepare the map storing all strings
    std::map<int, std::string> container;

    // Scan all boxes
    std::cout << "INFO: Parsing all boxes" << std::endl;
    for (auto it=d.Begin(); it!=d.End(); ++it)
    {
        // Stringify the DOM
        StringBuffer buffer;
        Writer<StringBuffer> writer(buffer);
        it->Accept(writer);

        // Save it in the correct image ID
        int id = it->operator[]("image_id").GetInt();
        if (container.count(id))
            container[id].append(",").append(buffer.GetString());
        else
            container[id] = buffer.GetString();
    }
    std::cout << "      Done" << std::endl;

    // Close general file
    fclose(fp);

    // Write each image in a separate file
    std::cout << "INFO: Writing all files" << std::endl;
    for(auto it=container.begin(); it!=container.end(); ++it)
    {
        // Get the filename
        std::ostringstream filename;
        filename << out_folder;
        filename << "/COCO_val2014_";
        filename.width(12);
        filename.fill('0');
        filename << it->first << ".json";

        // Write to the output
        std::ofstream ofs;
        ofs.open (filename.str(), std::ofstream::out | std::ofstream::app);
        ofs << "[" << it->second << "]";
    }
    std::cout << "      Done" << std::endl;

    return 0;
}
