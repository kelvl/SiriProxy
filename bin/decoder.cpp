#include <iostream>
#include <fstream>
#include <speex/speex.h>
#include <cmath>
#include <list>

using namespace std;

struct frame_pointers {
int size;
unsigned char* begin;
};
int main(int argc, char ** argv) {
unsigned char * data;
ifstream inFile;
int size = 0;
inFile.open(argv[1], ios::in | ios::binary);
cout << argc;
cout << "Attempting to open " << argv[1] << "\n";
if (inFile.is_open())
{
inFile.seekg (0, ios::end);
size = inFile.tellg();
data = new unsigned char [size];
inFile.seekg (0, ios::beg);
inFile.read((char*)data, size);
inFile.close();
}
else cout << "Unable to open File";
if (data != NULL)
{
cout << "File successfully read \n";
//Time to split the file using 10 null characters
int count = 0;
int frame_number = 0;
int frame_start = 0;
list<frame_pointers *> frames;
for (int i=0;i<size; i++)
{
if (data[i]=='\0')
count++;
else
count=0;
if (count == 10)
{
cout<<"Decoding frame " << ++frame_number << "\n";
frame_pointers *  temp = new frame_pointers;
temp->size = i-frame_start-9;
temp->begin = &data[frame_start];
frames.push_back(temp);
frame_start = i+1;
}
}
SpeexBits bits;
void * dec_state;
speex_bits_init(&bits);
dec_state = speex_decoder_init(&speex_wb_mode);
int frame_size = 0;
speex_decoder_ctl(dec_state, SPEEX_GET_FRAME_SIZE, &frame_size);
cout << "Frame size is " << frame_size;
spx_int16_t *output = new spx_int16_t [frame_size];
ofstream outFile;
outFile.open(argv[2], ios::out| ios::binary);
list<frame_pointers *>::iterator i;
for (i=frames.begin(); i != frames.end(); ++i)
{
cout << "Pulling frame with address " << ((*i)->begin)-data << " and size " << ((*i)->size) <<"\n";
speex_bits_read_from(&bits, (char*)((*i)->begin), ((*i)->size));
cout << "Writing frame to output file... \n";
while (speex_decode_int(dec_state, &bits, output) == 0)
{
cout << "One block written\n";
outFile.write((char*)output, frame_size);
}
}
outFile.close();
}
else {
cout << "Failed to read file, closing\n";
return 0;
}
}
