({
    setSelectedProduct : function(component, event, helper) {
        const selectedProduct = component.find('ProductSelection').get('v.value');
        const theOli = component.get('v.oli');
        theOli.Product2Id = selectedProduct;
        component.set('v.oli', theOli);
    }
})