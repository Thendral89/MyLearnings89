global class MyTaskHighlightedPanel extends VisualEditor.DynamicPickList {

    global override VisualEditor.DataRow getDefaultValue() {
        return getDefaultHighlightedPanel();
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return getAllHighlightedPanel();
    }

    private static VisualEditor.DataRow getDefaultHighlightedPanel() {
        List<String> highlightedPanelList = new List<String>();
        highlightedPanelList.addAll(MyTaskConstants.getHighlightedPanelMap().keyset());

        return new VisualEditor.DataRow(MyTaskConstants.getHighlightedPanelByKey(highlightedPanelList[0]), highlightedPanelList[0]);
    }

    private static VisualEditor.DynamicPickListRows getAllHighlightedPanel () {
        VisualEditor.DynamicPickListRows  listValues = new VisualEditor.DynamicPickListRows();

        for(String panel : MyTaskConstants.getHighlightedPanelMap().keyset()) {
            VisualEditor.DataRow listItem = new VisualEditor.DataRow(MyTaskConstants.getHighlightedPanelByKey(panel), panel);
            listValues.addRow(listItem);
        }

        return listValues;
    }
}