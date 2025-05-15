/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Tarang V, April 2022
 */
import { LightningElement,api} from 'lwc';

export default class DisplayImage extends LightningElement {
    @api documentid;
    file;
    
    
    connectedCallback() {
        this.file = {
            downloadUrl:"/sfc/servlet.shepherd/document/download/" +
            this.documentid}
        }
    filePreview() {
        const showPreview = this.template.querySelector("c-preview-file-modal");
        showPreview.show();
        }    
}