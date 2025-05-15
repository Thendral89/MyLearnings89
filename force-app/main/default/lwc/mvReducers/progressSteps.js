const INITIAL_STATE = {

}

export const progressSteps = (state = INITIAL_STATE, action) => {
    switch (action.type) {
        case "ADD_JOURNEYSTEPS":
            console.log('ADD_JOURNEYSTEPS--> ' + JSON.stringify(action.journeySteps));
            return action.journeySteps;
        default:
            return state;
    }
}