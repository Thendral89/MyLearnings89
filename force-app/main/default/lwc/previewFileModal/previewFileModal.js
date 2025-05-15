// Copyright © 2022 MaxVal Group. All Rights Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
// Developed by Punnam Guguloth (punnam.g@maxval.com) , APRIL 2022

import { LightningElement, api,track } from "lwc";

export default class PreviewFileModal extends LightningElement {
  @api url;
  @api fileExtension;
  @api filename;
  
  showFrame = false;
  showModal = false;
  // To show the file preview.
  @api show() {
    if (this.fileExtension === "pdf" || this.fileExtension === "application/pdf") this.showFrame = true;
    else this.showFrame = false;
    this.showModal = true;
  }
  // To close the file preview.
  closeModal() {
    this.showModal = false;
  }
}