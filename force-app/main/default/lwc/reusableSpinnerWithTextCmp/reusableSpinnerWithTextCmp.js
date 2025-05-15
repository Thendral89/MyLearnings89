/**
 * Name : ReusableSpinnerWithTextCmp
 * @description : This is the component which can be used to show spinner with text.
 * @author : Deloitte
 * @date : 08/30/2022.
*/
import { LightningElement, api } from 'lwc';

export default class ReusableSpinnerWithTextCmp extends LightningElement {
    @api spinnerText = ''; //varaible to display text below spinner
    @api spinnerSize = 'medium'; // variable to display size of spinner,accepted sizes are small, medium, and large
    @api spinnerVariant = 'base'; // variable for appearance of spinner,accepted variants include base, brand, and inverse
    @api helpText=''; // variable to describe the reason for the wait and need for a spinner
}