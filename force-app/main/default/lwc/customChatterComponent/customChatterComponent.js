import { LightningElement,track,api,wire } from 'lwc';
import getRelatedFeeds from '@salesforce/apex/CustomChatterUtility.getRelatedFeeds';
import { refreshApex } from '@salesforce/apex';
import { subscribe, MessageContext } from 'lightning/messageService';
import CUSTOM_CHATTER_COMPONENT_CHANNEL from '@salesforce/messageChannel/Custom_Chatter_Component__c';
export default class CustomChatterComponent extends LightningElement {
    @track inputValue = '';
    @api recordId;
    @track isLoading = true;
    @track feedData;
    @track showmodal=false;
    @track Searchterm;
    
    popOverVisible = false;
    type = 'FeedItem';
    wiredFeedResults;
    messageForModal = {};
    subscription = null;
    messageFromPost;
    

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CUSTOM_CHATTER_COMPONENT_CHANNEL,
            (message) => {
                console.log('message:'+JSON.stringify(message));
                
                if (message && message.type === 'Refresh') {
                    this.handleRefresh();
                }
            }
        );
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
        console.log('recordId', this.recordId); // Log the recordId to ensure it's set
    }

    @wire(getRelatedFeeds, { targetObjectId: '$recordId' })
    wiredFeeds(result) {
        this.wiredFeedResults = result;
        const { data, error } = result;
        if (data) {
            this.isLoading = false;
            this.feedData = data;
            console.log('data##', JSON.stringify(this.feedData));
        }
        if (error) {
            this.isLoading = false;
            console.log('error###', error);
        }
    }

    handleFilters(event){
        if(event.target.value === 'Latest Posts'){
            this.handleRefresh();
        }
        else if(event.target.value === 'Most Recent Activity'){
            
        }
    }
    
    handleSearch(evt) {
        console.log('search clicked');
        // const isEnterKey = evt.keyCode === 13;
        this.Searchterm = evt.target.value;
                
            if (this.Searchterm) {
                console.log(
                    'search term',
                    this.Searchterm);
                
                const searchTermLower = this.Searchterm.toLowerCase();
                // Filter from wiredFeedResults.data instead of feedData
                let filteredData = this.wiredFeedResults.data.filter(feedItem => {
                    // Check if the search term is in the feed item body
                    let inFeedItem = feedItem.feedItem.Body.toLowerCase().includes(searchTermLower);
                    console.log('inFeedItem ', inFeedItem);
                
                    // If the search term is not in the feed item body, check the comments
                    let inFeedComment = false;
                    if (!inFeedItem) {
                        inFeedComment = feedItem.feedItem.FeedComments?.some(comment =>
                            comment.CommentBody.toLowerCase().includes(searchTermLower)
                        );
                        console.log('inFeedComment ', inFeedComment);
                    }
                    return inFeedItem || inFeedComment;
                });
                console.log('filteredData ', JSON.stringify(this.filteredData));    
                if(filteredData){
                    this.feedData = filteredData;
                }else{
                    this.feedData = [];
                } 

            } else {
                this.feedData = this.wiredFeedResults.data;
            }
    }

    handleClearSearch(){
        console.log('clear click');
        this.feedData = this.wiredFeedResults.data;    
    }

    handleRefresh(){
        console.log('refresh clicked');
            this.Searchterm = ''
            this.isLoading = true;
            return refreshApex(this.wiredFeedResults)
                .then(() => {
                    this.isLoading = false;  
                })
                .catch(error => {
                    console.error('Error refreshing data:', error);
                    this.isLoading = false;  
            }); 
        }
        
    }