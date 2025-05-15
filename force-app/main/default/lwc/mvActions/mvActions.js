export const updateTimezone = (timezone) => {
    return {
        type: 'UPDATE_TIMEZONE',
        timezone: timezone
    };
};

export const resetReducers = () => {
    return {
        type: 'RESET'
    };
};

export const updateClientId = (client) => {
    return {
        type: 'UPDATE_CLIENT_ID',
        client: client
    };
};

export const updateApplicantAddress = (applicantAddress) => {
    return {
        type: 'UPDATE_APPLICANTADDRESS',
        applicantAddress: applicantAddress
    };
};

export const changePage = (targetPage, currentPage) => {
    if (!currentPage) {
        return {
            type: 'CHANGE_PAGE',
            targetPage: targetPage
        }
    }
    return {
        type: 'CHANGE_PAGE',
        targetPage: targetPage,
        currentPage: currentPage
    };
}


export const addApplicantAddress = (customer) => {
    return {
        type: 'UPDATE_APPLICANT',
        client: client
    };
};


export const refreshJourneyPage = (data) => {
    return {
        type: 'REFRESH_PAGES',
        pages: data
    };
};

export const addJourneySteps = (results) => {
    return {
        type: 'ADD_JOURNEYSTEPS',
        journeySteps: results
    };
};

export const addStepGroups = (results) => {
    return {
        type: 'ADD_STEPGROUPS',
        stepGroups: results
    };
};

export const updateJourneyType = (type) => {
    return {
        type: 'UPDATE_JOURNEY_TYPE',
        journeyType: type
    };
};

export const changePage2 = (newPage, oldPage, journeyType) => {
    return {
        type: 'CHANGE_PAGE_NEW',
        newPage: newPage,
        oldPage: oldPage,
        journeyType: journeyType
    };
};

export const updateJourneyTypePage = (oldPage, journeyType) => {
    return {
        type: 'UPDATE_JOURNEY_TYPE_PAGE',
        oldPage: oldPage,
        journeyType: journeyType
    }
}

export const disablePage = (pageName, journeyType) => {
    return {
        type: 'DISABLE_PAGE',
        pageName: pageName,
        journeyType: journeyType
    };
};

export const updateValidateResponse = (validateResponse) => {
    return {
        type: 'UPDATE_VALIDATE_RESPONSE',
        payload: validateResponse
    };
};

export const addError = (error) => {
    return {
        type: 'ADD_ERROR',
        payload: error
    };
};


export const addAddress = (customer) => {
    return {
        type: 'UPDATE_ADDRESS',
        customer: customer
    };
};

export const setIntakeParameters = (intakeParameters) => {
    return {
        type: 'SET_INTAKE_PARAMETERS',
        intakeParameters: intakeParameters
    };
};