package org.joget.marketplace;

import java.util.HashMap;
import java.util.Map;
import org.joget.apps.app.service.AppPluginUtil;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.datalist.model.DataList;
import org.joget.apps.datalist.model.DataListActionDefault;
import org.joget.apps.datalist.model.DataListActionResult;
import org.joget.apps.datalist.model.DataListPluginExtend;
import org.joget.commons.util.LogUtil;
import org.joget.plugin.base.PluginManager;

/**
 * Row action equivalent of OpenSliderListFormatter: opens its target (a URL
 * or Userview Menu ID) in a right-hand slider panel instead of navigating
 * away, using the Datalist Action + DataListPluginExtend plugin types
 * instead of a column formatter.
 *
 * DataListAction has no hook for a custom onclick on the <a> it renders, so
 * this relies on the "link_&lt;id&gt;" CSS class DataListDecorator.generateLink()
 * always attaches to a row action's link, and wires it up client-side (see
 * /template/sliderActionTrigger.ftl) via the HTML DataListPluginExtend lets
 * a plugin inject once per DataList render. getTarget() is left as "_self"
 * so the link is still a real, working link if that script fails to load.
 */
public class OpenSliderDataListAction extends DataListActionDefault implements DataListPluginExtend {

    private final static String MESSAGE_PATH = "messages/OpenSliderDataListAction";

    @Override
    public String getName() {
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderDataListAction.pluginLabel", getClassName(), MESSAGE_PATH);
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
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderDataListAction.pluginLabel", getClassName(), MESSAGE_PATH);
    }

    @Override
    public String getDescription() {
        //support i18n
        return AppPluginUtil.getMessage("org.joget.marketplace.OpenSliderDataListAction.pluginDesc", getClassName(), MESSAGE_PATH);
    }

    @Override
    public String getPropertyOptions() {
        return AppUtil.readPluginResource(getClassName(), "/properties/OpenSliderDataListAction.json", null, true, MESSAGE_PATH);
    }

    @Override
    public String getIcon() {
        return "<i class=\"fas fa-external-link-alt\"></i>";
    }

    @Override
    public String getLinkLabel() {
        String label = getPropertyString("label");
        return (label != null && !label.isEmpty()) ? label : "Open";
    }

    @Override
    public String getHref() {
        return getPropertyString("href");
    }

    @Override
    public String getTarget() {
        // Real fallback target: if the trigger-wiring script below fails to
        // load for any reason, the link still works as a plain navigation
        // instead of doing nothing.
        return "_self";
    }

    @Override
    public String getHrefParam() {
        return getPropertyString("hrefParam");
    }

    @Override
    public String getHrefColumn() {
        return getPropertyString("hrefColumn");
    }

    @Override
    public String getConfirmation() {
        return getPropertyString("confirmation");
    }

    @Override
    public Boolean supportColumn() {
        // The "link_<id>" marker class this relies on to wire up its click
        // handler is only added by DataListDecorator for row actions.
        return false;
    }

    @Override
    public Boolean supportList() {
        return false;
    }

    @Override
    public DataListActionResult executeAction(DataList dataList, String[] rowKeys) {
        // The click is always intercepted client-side (see getHTML()/
        // sliderActionTrigger.ftl) before the browser would ever submit
        // back to the server, so this should not normally run.
        return new DataListActionResult();
    }

    @Override
    public String getHTML(DataList dataList) {
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

        String html = pluginManager.getPluginFreeMarkerTemplate(model, getClassName(), "/template/slider.ftl", null);

        String id = getPropertyString("id");
        if (id == null || id.isEmpty()) {
            LogUtil.warn(getClassName(), "Missing builder-assigned 'id' property; skipping slider trigger wiring, link will behave as a normal hyperlink");
            return html;
        }

        Map triggerModel = new HashMap();
        triggerModel.put("linkClass", "link_" + id);
        html += pluginManager.getPluginFreeMarkerTemplate(triggerModel, getClassName(), "/template/sliderActionTrigger.ftl", null);

        return html;
    }
}
