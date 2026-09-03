package org.joget.marketplace;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;
import org.joget.apps.app.service.AppPluginUtil;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.datalist.model.DataList;
import org.joget.apps.datalist.model.DataListColumn;
import org.joget.apps.datalist.model.DataListColumnFormatDefault;
import org.joget.apps.datalist.service.DataListService;
import org.joget.commons.util.LogUtil;
import org.joget.plugin.base.PluginManager;
import org.joget.workflow.util.WorkflowUtil;

public class OpenSliderListFormatter extends DataListColumnFormatDefault {

    private final static String MESSAGE_PATH = "messages/OpenSliderListFormatter";

    @Override
    public String getName() {
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderListFormatter.pluginLabel", getClassName(), MESSAGE_PATH);
    }

    @Override
    public String getVersion() {
        return "8.0.6";
    }

    @Override
    public String getClassName() {
        return getClass().getName();
    }

    @Override
    public String getLabel() {
        //support i18n
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderListFormatter.pluginLabel", getClassName(), MESSAGE_PATH);
    }

    @Override
    public String getDescription() {
        //support i18n
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderListFormatter.pluginDesc", getClassName(), MESSAGE_PATH);
    }

    @Override
    public String getPropertyOptions() {
        return AppUtil.readPluginResource(getClassName(), "/properties/OpenSliderListFormatter.json", null, true, MESSAGE_PATH);
    }

    public String getHref() {
        return getPropertyString("href");
    }

    public String getHrefParam() {
        return getPropertyString("hrefParam");
    }

    public String getHrefColumn() {
        return getPropertyString("hrefColumn");
    }

    public String getTabNameColumn() {
        return getPropertyString("tabNameColumn");
    }

    public String getTabName(DataList dataList, Object row, Object value) {
        String tabNameColumn = getTabNameColumn();

        if (tabNameColumn != null && !tabNameColumn.isEmpty()) {
            // Use the specified column for tab name
            try {
                Object columnValue = DataListService.evaluateColumnValueFromRow(row, tabNameColumn);
                if (columnValue != null && !columnValue.toString().trim().isEmpty()) {
                    return columnValue.toString().trim();
                }
            } catch (Exception e) {
                LogUtil.warn(getClassName(), "Error getting tab name from column '" + tabNameColumn + "': " + e.getMessage());
            }
        }

        //fallback to the hyperlink label (previous default behaviour)
        return getLinkLabel(dataList, row, value);
    }

    public String getLinkLabel(DataList dataList, Object row, Object value) {
        String label = getPropertyString("label");

        if (label != null && !label.isEmpty()) {
            Pattern pattern = Pattern.compile("\\{([^\\}]+)\\}");
            Matcher matcher = pattern.matcher(label);

            if (!matcher.find()) {
                return label;
            }

            matcher.reset();
            StringBuffer processedLabel = new StringBuffer();

            while (matcher.find()) {
                String columnName = matcher.group(1);
                Object columnValue = DataListService.evaluateColumnValueFromRow(row, columnName);
                String replacement;

                if (columnValue != null && !columnValue.toString().trim().isEmpty()) {
                    replacement = columnValue.toString();
                } else if (value != null && !value.toString().trim().isEmpty()) {
                    // Use current column value as fallback
                    replacement = value.toString();
                } else {
                    // Final fallback
                    replacement = "Hyperlink";
                }

                matcher.appendReplacement(processedLabel, Matcher.quoteReplacement(replacement));
            }

            matcher.appendTail(processedLabel);

            String finalLabel = processedLabel.toString().trim();
            return finalLabel.isEmpty() ? "Hyperlink" : finalLabel;
        } else if (value != null && !value.toString().trim().isEmpty()) {
            return value.toString();
        } else {
            return "Hyperlink";
        }
    }

    @Override
    public String format(DataList dataList, DataListColumn dlc, Object row, Object value) {
        String content = "";
        HttpServletRequest request = WorkflowUtil.getHttpServletRequest();

        if (request != null && request.getAttribute(getClassName()) == null) {

            PluginManager pluginManager = (PluginManager) AppUtil.getApplicationContext().getBean("pluginManager");
            Map model = new HashMap();
            boolean multiTabEnabled = "true".equalsIgnoreCase(getPropertyString("multiTabSlider"));

            model.put("element", this);
            if (getPropertyString("width") != null) {
                model.put("width", getPropertyString("width"));
            } else {
                model.put("width", "50%");
            }
            model.put("dockBackground",
                    (getPropertyString("dockBackground") != null && !getPropertyString("dockBackground").isEmpty())
                    ? getPropertyString("dockBackground")
                    : "linear-gradient(135deg, rgba(17, 23, 53, 0.95), rgba(33, 45, 85, 0.95))");

            model.put("multiTabEnabled", multiTabEnabled);

            model.put("tabBackground",
                    (getPropertyString("tabBackground") != null && !getPropertyString("tabBackground").isEmpty())
                    ? getPropertyString("tabBackground")
                    : "#ffffff1f");

            model.put("tabActiveBackground",
                    (getPropertyString("tabActiveBackground") != null && !getPropertyString("tabActiveBackground").isEmpty())
                    ? getPropertyString("tabActiveBackground")
                    : "#007bff");

            model.put("tabTextColor",
                    (getPropertyString("tabTextColor") != null && !getPropertyString("tabTextColor").isEmpty())
                    ? getPropertyString("tabTextColor")
                    : "#ffffffe6");

            model.put("tabPadding",
                    (getPropertyString("tabPadding") != null && !getPropertyString("tabPadding").isEmpty())
                    ? getPropertyString("tabPadding")
                    : "8px 16px");

            model.put("tabMinWidth",
                    (getPropertyString("tabMinWidth") != null && !getPropertyString("tabMinWidth").isEmpty())
                    ? getPropertyString("tabMinWidth")
                    : "120px");

            model.put("tabMaxWidth",
                    (getPropertyString("tabMaxWidth") != null && !getPropertyString("tabMaxWidth").isEmpty())
                    ? getPropertyString("tabMaxWidth")
                    : "200px");

            model.put("tabListGap",
                    (getPropertyString("tabListGap") != null && !getPropertyString("tabListGap").isEmpty())
                    ? getPropertyString("tabListGap")
                    : "6px");

            model.put("tabListPadding",
                    (getPropertyString("tabListPadding") != null && !getPropertyString("tabListPadding").isEmpty())
                    ? getPropertyString("tabListPadding")
                    : "0 8px");

            model.put("tabCloseButtonOpacity",
                    (getPropertyString("tabCloseButtonOpacity") != null && !getPropertyString("tabCloseButtonOpacity").isEmpty())
                    ? getPropertyString("tabCloseButtonOpacity")
                    : "0.7");

            model.put("buttonBackground",
                    (getPropertyString("buttonBackground") != null && !getPropertyString("buttonBackground").isEmpty())
                    ? getPropertyString("buttonBackground")
                    : "#6c757d26");

            model.put("buttonHoverBackground",
                    (getPropertyString("buttonHoverBackground") != null && !getPropertyString("buttonHoverBackground").isEmpty())
                    ? getPropertyString("buttonHoverBackground")
                    : "#dc3545cc");

            model.put("controlButtonSize",
                    (getPropertyString("controlButtonSize") != null && !getPropertyString("controlButtonSize").isEmpty())
                    ? getPropertyString("controlButtonSize")
                    : "36px");

            model.put("controlsGap",
                    (getPropertyString("controlsGap") != null && !getPropertyString("controlsGap").isEmpty())
                    ? getPropertyString("controlsGap")
                    : "8px");

            model.put("fontSize",
                    (getPropertyString("fontSize") != null && !getPropertyString("fontSize").isEmpty())
                    ? getPropertyString("fontSize")
                    : "14px");

            model.put("fontWeight",
                    (getPropertyString("fontWeight") != null && !getPropertyString("fontWeight").isEmpty())
                    ? getPropertyString("fontWeight")
                    : "500");

            model.put("borderRadius",
                    (getPropertyString("borderRadius") != null && !getPropertyString("borderRadius").isEmpty())
                    ? getPropertyString("borderRadius")
                    : "16px");

            model.put("dockHeight",
                    (getPropertyString("dockHeight") != null && !getPropertyString("dockHeight").isEmpty())
                    ? getPropertyString("dockHeight")
                    : "60px");

            model.put("dockPadding",
                    (getPropertyString("dockPadding") != null && !getPropertyString("dockPadding").isEmpty())
                    ? getPropertyString("dockPadding")
                    : "8px 12px");

            content += pluginManager.getPluginFreeMarkerTemplate(model, getClass().getName(), "/template/slider.ftl", null);

            request.setAttribute(getClassName(), true);
        }

        String url = getHref();
        String hrefParam = getHrefParam();
        String hrefColumn = getHrefColumn();

        if (hrefParam != null && hrefColumn != null && !hrefColumn.isEmpty()) {
            //DataListCollection rows = dataList.getRows();
            //String primaryKeyColumnName = dataList.getBinder().getPrimaryKeyColumnName();

            String[] params = hrefParam.split(";");
            String[] columns = hrefColumn.split(";");

            for (int i = 0; i < columns.length; i++) {
                if (columns[i] != null && !columns[i].isEmpty()) {
                    boolean isValid = false;
                    if (params.length > i && params[i] != null && !params[i].isEmpty()) {
                        if (url.contains("?")) {
                            url += "&";
                        } else {
                            url += "?";
                        }
                        url += params[i];
                        url += "=";
                        isValid = true;
                    } else if (!url.contains("?")) {
                        if (!url.endsWith("/")) {
                            url += "/";
                        }
                        isValid = true;
                    }

                    if (isValid) {
                        String val = DataListService.evaluateColumnValueFromRow(row, columns[i]).toString();
                        url += val + ";";
                        //url += getValue(row, columns[i]) + ";";
                        url = url.substring(0, url.length() - 1);
                    }
                }
            }
        }

        String displayStyle = getProperty("link-css-display-type").toString();
        displayStyle += " noAjax no-close";

        String tabTitle = getTabName(dataList, row, value).replace("'", "\\'");
        return content + "<a class=\"" + displayStyle + "\" onClick=\"openSlider('" + url + "', '" + tabTitle + "')\">"
                + getLinkLabel(dataList, row, value) + "</a>";
    }
}
