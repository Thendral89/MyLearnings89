import { LightningElement } from 'lwc';

export default class imageResize extends LightningElement {
    width;
    height;
compressImage() {
    console.log('width ')
    let img = new Image();
// get the image
img.src = '//cdn.programiz.com/sites/tutorial2program/files/cover-artwork.png';

// get height and width
img.onload = function() {
  console.log('width ' + this.width)
  console.log('height '+ this.height);
}
}
}