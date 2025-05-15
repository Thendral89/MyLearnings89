const INITIAL_ADDRESS_STATE = {
    "applicantAddress": {
        city: '',
        zipCode: '',
        state: '',
        address1: '',
        address2: '',
        country: ''
    }
}

export const applicantAddress = (state = INITIAL_ADDRESS_STATE, action) => {
    //console.log('redux dta'+  JSON.stringify(action.billingAddress.accountBillingAddress));
    console.log('check tyoe' + action.type);
    switch (action.type) {
        case "UPDATE_APPLICANTADDRESS":
            return {
                ...state,
                applicantAddress: action.applicantAddress.applicantAddress
            }

        default:
            return state;

    }

}