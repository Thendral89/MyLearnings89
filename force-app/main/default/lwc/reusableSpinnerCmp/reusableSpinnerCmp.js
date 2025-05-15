import { LightningElement, api } from 'lwc';

export default class ReusableSpinnerCmp extends LightningElement {
    @api showModalSpinner;
    spinnerAltText= 'loading';
    spinnerSize= 'medium';
    spinnerVariant= "brand";
}