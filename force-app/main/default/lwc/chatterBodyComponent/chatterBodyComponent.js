import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import createFeedComment from '@salesforce/apex/CustomChatterUtility.createFeedComment';
import manageLike from '@salesforce/apex/CustomChatterUtility.manageLike';
import CUSTOM_CHATTER_COMPONENT_CHANNEL from '@salesforce/messageChannel/Custom_Chatter_Component__c';
export default class ChatterBodyComponent extends LightningElement {
    @track showmodal=false;
    @track feed;
    @track isLiked = false;
    popOverVisible = false;
    messageForModal = {};
    type = 'FeedComment';
    @wire(MessageContext)
    messageContext;
    url ='/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=068NS00000K8mtZYAR&operationContext=CHATTER&contentId=069NS00000LHMo1YAH'

    get buttonText() {
        return this.isLiked ? 'Liked' : 'Like';
    }

    get iconClass() {
        return this.isLiked ? 'like-icon filled' : 'like-icon';
    }

    get textClass() {
        return this.isLiked ? 'slds-p-left_x-small liked-text' : 'slds-p-left_x-small';
    }

    @api
    get values(){
        return this.feed;
    }
    set values(value){
        console.log(
            'set values',
            JSON.stringify(value));
        this.feed = value;
        this.isLiked = value.feedItem.IsLiked;
    }
    
    handleLikeClick() {
        this.isLiked = !this.isLiked;
        try {
            console.log('called');
            
            manageLike({mark:this.isLiked,feedItemId:this.feed.feedItem.Id})
            .then(result=>{
                console.log('result ', result);
            })
            .catch(error=>{
                console.log('error ',error.body.message);
            });
        } catch (error) {
            console.log('error ',error.body.message);
            
        }
        

    }
    handlePreview(){
        console.log('preview');
        
    }
    handleComment(){
        this.template.querySelector("c-post-component").handleInputClick();
    }
    
    handleshowmodal(event) {
        console.log('Modal button clicked');
        this.showmodal = !this.showmodal;
        if(event.detail){
            let buttonName = event.detail.buttonName;
            console.log('button name',buttonName);
            if(buttonName === 'Delete'){
                const message = {
                    type: 'Refresh',
                    data: ''
                }
                publish(this.messageContext, CUSTOM_CHATTER_COMPONENT_CHANNEL, message);
            }
        }
    }
   
    handleCreateFeedComment(event){
        let CommentBody = event.detail;
        let feedItemId; 
        const element = this.template.querySelector('.mainbody');
        console.log('parentLi',element);
    
        if (element) {
            feedItemId = element.dataset.id;
            console.log('Using parent feed id:', feedItemId);

            if(CommentBody && feedItemId){ 
                createFeedComment({CommentBody:CommentBody,FeedItemId:feedItemId})
                .then(reuslt=>{
                    console.log('result ', reuslt);
                    this.showToast('Success','success','Comment shared successfully');
                    publish(this.messageContext, CUSTOM_CHATTER_COMPONENT_CHANNEL, {});
                })
                .catch(error=>{
                    console.log('error ',error.body.message);
                    this.showToast('Error','Error',error.body.message);
                });
            }
        }else{
            console.log('No parent feed id');
        }
        
    }
    handleFeedAction(e){
        if(e.target.label === 'Delete'){
            const feedItemElement = e.target.closest('[data-id]');
            const feedItemId = feedItemElement.dataset.id;
            console.log('Delete clicked feeditem id',feedItemId);
            this.messageForModal.Title = "Delete Post";
            this.messageForModal.Body = "Deleting this item permanently removes it. We're just making sure that's what you want.";
            this.messageForModal.Id = feedItemId;
            this.messageForModal.ButtonName = 'Delete';
            this.showmodal = true;
        }
    }

    handleFeedCommentAction(e){
        if(e.target.label ==='Delete'){
            const feedCommentElement = e.target.closest('[data-feed-comment-id]');
            const feedCommentId = feedCommentElement.dataset.feedCommentId;
            console.log('Delete clcked and feed comment id: ',feedCommentId);
            this.messageForModal.Title = "Delete Comment";
            this.messageForModal.Body = "Deleting this item permanently removes it. We're just making sure that's what you want.";
            this.messageForModal.Id = feedCommentId;
            this.messageForModal.ButtonName = 'Delete';
            this.showmodal = true;
            console.log('this.showmodal',this.showmodal);
            
        }
    }
    handleCloseModal(){
        this.showmodal = false;
        
    }
    showToast(title,variant,message){ 
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
    

}