const INITIAL_STATE = {

}

export const stepGroups =  (state = INITIAL_STATE , action) =>
 {
    switch (action.type) {      
        case "ADD_STEPGROUPS":
                return action.stepGroups;
        default: 
            return state;
    }
}