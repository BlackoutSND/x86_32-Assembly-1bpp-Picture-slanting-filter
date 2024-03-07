# x86_32-Assembly-1bpp-Picture-slanting-filter
A small project, the idea behind which is to modify a picture from x86_32 Assembly code.
The way it should modify the picture:
  Pixels in each row move to the right depending on their row's position. So, everything in the first row will be displaced by 1 and in the 10th by 10;
  If a pixel gets over the picture width it should wrap around and appear at the beggining of the row.
  That's it.
  Limitation: The picture has to be 1bpp -> black and white without alpha.
