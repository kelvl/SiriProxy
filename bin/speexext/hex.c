#include <stdio.h>
#include <string.h>
#include <speex/speex.h>

unsigned char _hexCharToInteger(unsigned char hexChar) {
    if (hexChar >= '0' && hexChar <= '9') {
        return (hexChar - '0') & 0xF;
    } else {
        return ((hexChar - 'A')+10) & 0xF;
    }
}

int populateBytesFromHexString(unsigned char * data, char * string){
	const char * hexString = string;
	int dataLength = strlen(string) / 2;
	if(data == NULL){
		return 0; 
	}
	int i = 0;
	for(i=0; i < dataLength; i++){
		unsigned char firstByte = hexString[2*i];
		unsigned char secondByte = hexString[2*i+1];
		unsigned char byte = (_hexCharToInteger(firstByte) << 4) + _hexCharToInteger(secondByte);
		data[i] = byte;
	}
	return dataLength;
}

int main(int argc, char **argv){
	
	SpeexBits decodeBits;
	void *dec_state;
	
	speex_bits_init(&decodeBits);
	dec_state = speex_decoder_init(&speex_wb_mode);
	int frame_size = 0;
	speex_decoder_ctl(dec_state, SPEEX_GET_FRAME_SIZE, &frame_size);
	
	spx_int16_t * decodedOutput = malloc(sizeof(spx_int16_t) * frame_size);
	
	SpeexBits encodeBits;
	void *enc_state;
	
	speex_bits_init(&encodeBits);
	enc_state = speex_encoder_init(&speex_wb_mode);
	int quality = 8;
	speex_encoder_ctl(enc_state, SPEEX_SET_QUALITY, &quality);
	int vbr = 1;
	speex_encoder_ctl(enc_state, SPEEX_SET_VBR, &vbr);
		
		char line [1400];

		unsigned char buf[700];
		
		char encBits[80];
		
		while(fgets(line, sizeof line, stdin) != NULL){
			
			int length = populateBytesFromHexString(buf, line);
			
			fprintf(stderr, "%d \n", length);
			
			speex_bits_reset(&decodeBits);
			
			speex_bits_read_from(&decodeBits, buf, length);
			
			while(speex_decode_int(dec_state, &decodeBits, decodedOutput) == 0){
				// decoded pcm stored in decodedOutput 320 samples
				
				// print out the pcm output
				//fwrite(decodedOutput, frame_size, sizeof(spx_int16_t), stdout);
				
				speex_bits_reset(&encodeBits);
				
				speex_encode_int(enc_state, decodedOutput, &encodeBits);
				int encoded_frame_length = speex_bits_write(&encodeBits, encBits, 80);
				char encoded_frame_length_byte = (char) encoded_frame_length;				
				
				fwrite(&encoded_frame_length_byte, sizeof(char), 1, stdout);
				fwrite(encBits, 1, encoded_frame_length, stdout);
			}
		}
		
	free(decodedOutput);
	speex_bits_destroy(&encodeBits);
	speex_encoder_destroy(enc_state);
	speex_bits_destroy(&decodeBits);
	speex_decoder_destroy(dec_state);

	return 0;
}