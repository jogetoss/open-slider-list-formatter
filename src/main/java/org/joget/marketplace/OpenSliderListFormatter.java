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
        return "8.0.4";
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
            model.put("element", this);
            if (getPropertyString("width") != null) {
                model.put("width", getPropertyString("width"));
            } else {
                model.put("width", "50%");
            }

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

        return content + "<a class=\"" + displayStyle + "\" onClick=\"openSlider('" + url + "')\">" + getLinkLabel(dataList, row, value) + "</a>";
    }
}
