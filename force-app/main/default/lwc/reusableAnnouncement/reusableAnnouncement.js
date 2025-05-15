import { LightningElement, api, track } from 'lwc';
import myPNG_icon from '@salesforce/resourceUrl/announcement';
import chevrondown from '@salesforce/resourceUrl/down';
export default class Announcement extends LightningElement {
    announcement_icon =myPNG_icon;
    @api iconName = "utility:announcement";
    @api announcementheader;
    @api announcements;
    @api announcementlink;
    @api announcementheaderSp;
    @api announcementsSp;
    @api announcementlinkSp;
    header;
    body;
    link;
    @api showLanguages = false;
    @api langSelected = false;
    @track selectedOption;
    @api containerstyleclass="defaultcontainerstyleclass";

    @api showasdottedlist = false;
    get selectStyle(){
        return `-webkit-appearance: none;
        background-color: white;
        background-image: url(${chevrondown});
        background-repeat: no-repeat;
        background-position: 95% 50%;
        background-size: 10px;
        width: 144px`
    }

    connectedCallback(){
        this.header = this.announcementheader;
        this.body = this.announcements;
        console.log ('Body : ' + this.body);
        this.link = this.announcementlink;
    }

    changeHandler(event) {
        const field = event.target.name;
        if (field === 'optionSelect') {
                this.selectedOption = event.target.value;
              //  alert("you have selected : "+this.selectedOption);
                if (this.selectedOption =="SP") {
                    this.langSelected =true;
                    this.header = this.announcementheaderSp;
                    this.body = this.announcementsSp;
                    this.link = this.announcementlinkSp;
                }else if(this.selectedOption =="EN"){
                    this.langSelected =false;
                    this.header = this.announcementheader;
                    this.body = this.announcements;
                    this.link = this.announcementlink;
                }
            } 
        }
    

    /**
	 * @description send/fire an event when link selected.
	 */
    handleSelectedLink(event){
		let params = {
            Id: event.target.dataset.targetId
		}

		this.sendEvent(
			'genericlinkevent',
			params
		);
    }
    /**
	 * @description Generic function to send/fire an event. All the events will be sent to
	 * the immediate parent.
	 * @param {String} eventName Name of the event.
	 * @param {Object} parameters data to send to the parent.
	 */
	sendEvent(eventName, parameters) {
		let eventData = {
			detail: parameters
		};
		this.dispatchEvent(new CustomEvent(eventName, eventData));
	}
}