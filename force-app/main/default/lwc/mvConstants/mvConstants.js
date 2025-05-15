export const memRoles = {
    SYSADMIN: { value: 'SYSADMIN', label: 'System Administrator' },
    ATTORNEY: { value: 'ATTORNEY', label: 'Attorney' },
    PARALEGAL: { value: 'PARALEGAL', label: 'Paralegal' },
    getLabel: value => { return memRoles[value] ? memRoles[value].label : value; }
}

export const assetAPINames = {
    PATENT: { value: 'SymphonyLF__Patent__c', label: 'Patent' },
    TRADEMARK: { value: 'SymphonyLF__Trademark__c', label: 'Trademark' },
    getLabel: value => { return assetAPINames[value] ? assetAPINames[value].label : value; }
}

export const assetFieldAPINames = {
    PATENT_JURISDICTION: { value: 'SymphonyLF__Country__c', label: 'PATENT_JURISDICTION' },
    PATENT_CASE_TYPE: { value: 'SymphonyLF__Case_Type__c', label: 'PATENT_CASE_TYPE' },
    TRADEMARK: { value: 'SymphonyLF__Trademark__c', label: 'Trademark' },
    getLabel: value => { return assetAPINames[value] ? assetAPINames[value].label : value; }
}