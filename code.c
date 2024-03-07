#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void slantbmp1(void *img, int width, int height);
//void slantbpm64(void *img, int width, int height);

int main(int argc, char *argv[])
{
    printf("Name of bmp file: %s\n", argv[1]);
    char *end;
    char *img = argv[1];
    strcat(img, ".bmp");
    FILE *file = fopen(img, "rb");
    if (file == NULL){
        perror("Error opening file");
        return 1;
    }

    char *file_header = (char *)malloc(256);   //change 256 for other numbers if the header size is wrong
    fread(file_header, 1, 256, file);
    int offset = *(int *)(file_header + 10);
    int width = *(int *)(file_header + 18);
    int height = *(int *)(file_header + 22);
    int bpp = *(short *)(file_header + 28);
    int row_padded = ((width + 7) / 8 + 3) & (~3);  // Row size in bytes
    unsigned char* pixelData = malloc(height * row_padded);

    fseek(file, offset, SEEK_SET);
    fread(pixelData, sizeof(unsigned char), height * row_padded, file);
    printf("Width: %d, Height: %d, Size: %d, offset: %d, bpp: %d\n",
            width, height, height * row_padded, offset, bpp);
    fclose(file);
    if (bpp!= 1)
    {
        printf("The image is not black and white (1bpp). Application is terminated.\n");
        return 1;
    }


    slantbmp1(pixelData, width, height);
    //slantbpm64(pixelData, width, height);


    file = fopen("BRUH.bmp", "wb");
    if (file == NULL){
        perror("Error opening file");
        return 1;
    }
    fwrite(file_header, 1, offset, file);
    fwrite(pixelData, 1, height * row_padded, file);

    return 0;
}