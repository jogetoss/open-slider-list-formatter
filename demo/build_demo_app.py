#!/usr/bin/env python3
"""Generates demo/OpenSliderDemo.jwa, a sample Joget app for the Open Slider plugin.

    python3 demo/build_demo_app.py

Import it in Joget via App Center > Design New App > Import App and tick
"Import data" so the 8 sample customers are loaded.

The app has one form (Customer) and a detail view of it that the slider opens.
Each demo menu is a list of the same customers, set up differently:

  Single Slider      Open Slider List Formatter on the Name column
  Multi-tab Slider   same formatter with Multi Tab enabled (tabs dock at the bottom)
  Row Action         Open Slider DataList Action as a row action
  Top Window         a page that frames two lists (one formatter, one action), both
                     with Open In = Top window, the way a dashboard portlet does

Property ids and class names are the ones in src/main/resources/properties/
OpenSliderListFormatter.json and OpenSliderDataListAction.json. A .jwa is a zip
of appDefinition.xml plus data/<table>.json. It is not part of the Maven build
and does not embed the plugin jar, so install the plugin separately.
"""
import datetime
import json
import os
import uuid
import zipfile
import xml.etree.ElementTree as ET

APP_ID = "openSliderDemo"
APP_NAME = "Open Slider Demo"
APP_VERSION = "1"
TABLE = "osd_customer"
HERE = os.path.dirname(os.path.abspath(__file__))

FORMATTER = "org.joget.marketplace.OpenSliderListFormatter"
ACTION = "org.joget.marketplace.OpenSliderDataListAction"

# The slider opens this menu. "?embed=true" renders it without the userview
# chrome, and the formatter/action append "&id=<row id>".
DETAIL_HREF = "customer_detail?embed=true"


def plugin(cls="", **props):
    """className + properties: every plugin slot (validator, binder, formatter...).
    An empty call means "none configured"."""
    return {"className": cls, "properties": props}


def stable_id(key):
    return uuid.uuid5(uuid.NAMESPACE_DNS, "%s.%s" % (APP_ID, key)).hex.upper()


# ---------------------------------------------------------------------------
# Form
# ---------------------------------------------------------------------------
def text_field(fid, label, mandatory=False):
    return {"className": "org.joget.apps.form.lib.TextField", "properties": {
        "id": fid, "label": label, "value": "", "readonly": "", "placeholder": "", "readonlyLabel": "",
        "maxlength": "", "size": "", "encryption": "", "workflowVariable": "",
        "validator": plugin("org.joget.apps.form.lib.DefaultValidator", mandatory="true") if mandatory else plugin()}}


def text_area(fid, label):
    return {"className": "org.joget.apps.form.lib.TextArea", "properties": {
        "id": fid, "label": label, "value": "", "readonly": "", "readonlyLabel": "", "rows": "5",
        "workflowVariable": "", "validator": plugin()}}


def select_box(fid, label, options):
    return {"className": "org.joget.apps.form.lib.SelectBox", "properties": {
        "id": fid, "label": label, "value": options[0], "readonly": "", "readonlyLabel": "", "multiple": "",
        "size": "", "controlField": "", "workflowVariable": "",
        "options": [{"value": o, "label": o, "grouping": ""} for o in options],
        "optionsBinder": plugin(), "validator": plugin()}}


def form_json(form_id, name, elements):
    section = {
        "className": "org.joget.apps.form.model.Section",
        "properties": {"id": "section1", "label": name, "readonly": "", "readonlyLabel": "", "join": "",
                       "reverse": "", "visibilityControl": "", "visibilityValue": "", "regex": "",
                       "permissionReadonly": "", "comment": "",
                       "loadBinder": plugin(), "storeBinder": plugin(), "permission": plugin()},
        "elements": [{"className": "org.joget.apps.form.model.Column", "properties": {"width": "100%"},
                      "elements": elements}],
    }
    return {
        "className": "org.joget.apps.form.model.Form",
        "properties": {"id": form_id, "name": name, "tableName": TABLE, "description": "",
                       "noPermissionMessage": "", "postProcessorRunOn": "create",
                       "loadBinder": plugin("org.joget.apps.form.lib.WorkflowFormBinder"),
                       "storeBinder": plugin("org.joget.apps.form.lib.WorkflowFormBinder"),
                       "permission": plugin(), "postProcessor": plugin()},
        "elements": [section],
    }


# ---------------------------------------------------------------------------
# Datalists, built on the form's table so column names are the field ids
# ---------------------------------------------------------------------------
def column(cid, name, label, formatter=None):
    return {"id": cid, "name": name, "label": label, "filterable": True, "hidden": "false",
            "sortable": "true", "datalist_type": "column", "renderHtml": "", "exclude_export": "",
            "width": "", "style": "", "alignment": "", "headerAlignment": "",
            "action": plugin(), "format": formatter or plugin()}


def link_params():
    return {"hrefParam": "id", "hrefColumn": "id",
            "parameters": [{"hrefParam": "id", "hrefColumn": "id"}]}


def slider_formatter(label="{name}", css="btn btn-link", width="50%", open_in="", multi_tab=False):
    props = {"href": DETAIL_HREF, "label": label, "width": width, "openIn": open_in,
             "link-css-display-type": css, "multiTabSlider": "true" if multi_tab else ""}
    props.update(link_params())
    if multi_tab:
        props["tabNameColumn"] = "name"
    return plugin(FORMATTER, **props)


def slider_row_action(rid, label="Open", width="50%", open_in="", multi_tab=False):
    props = {"id": rid, "datalist_type": "row_action", "href": DETAIL_HREF, "label": label, "width": width,
             "openIn": open_in, "confirmation": "", "visible": "", "header_label": "",
             "link-css-display-type": "btn btn-sm btn-primary", "multiTabSlider": "true" if multi_tab else ""}
    props.update(link_params())
    return {"className": ACTION, "id": rid, "properties": props}


def list_json(list_id, name, name_formatter=None, row_actions=None, page_size="10"):
    return {
        "id": list_id, "name": name, "pageSize": page_size, "order": "", "orderBy": "name",
        "showPageSizeSelector": "true", "pageSizeSelectorOptions": "10,20,30,40,50,100",
        "buttonPosition": "bothLeft", "checkboxPosition": "left", "useSession": "false",
        "actions": [], "rowActions": row_actions or [], "filters": [],
        "binder": plugin("org.joget.plugin.enterprise.AdvancedFormRowDataListBinder", formDefId="customer"),
        "columns": [
            column("column_0", "id", "ID"),
            column("column_1", "name", "Name", name_formatter),
            column("column_2", "company", "Company"),
            column("column_3", "email", "Email"),
            column("column_4", "status", "Status"),
        ],
        "template": plugin(), "description": "",
    }


# ---------------------------------------------------------------------------
# Userview
# ---------------------------------------------------------------------------
def menu(cls, custom_id, label, **props):
    base = {"id": stable_id(custom_id), "customId": custom_id, "label": label,
            "userviewCacheDuration": "", "userviewCacheScope": "", "enableOffline": ""}
    base.update(props)
    return {"className": cls, "properties": base}


def datalist_menu(custom_id, label, list_id):
    return menu("org.joget.apps.userview.lib.DataListMenu", custom_id, label, datalistId=list_id,
                rowCount="true", selectionType="multiple", checkboxPosition="left", buttonPosition="bothLeft",
                keyName="", customHeader="", customFooter="", cacheAllLinks="", cacheListAction="")


def crud_menu(custom_id, label, list_id, form_id):
    return menu("org.joget.plugin.enterprise.CrudMenu", custom_id, label, datalistId=list_id,
                addFormId=form_id, editFormId=form_id, keyName="", rowCount="true", selectionType="multiple",
                checkboxPosition="left", buttonPosition="bothLeft", **{
                    "list-showDeleteButton": "yes", "list-moreActions": [], "edit-moreActions": [],
                    "add-afterSaved": "list", "edit-afterSaved": "list", "edit-readonly": "",
                    "edit-readonlyLabel": "true"})


def form_menu_readonly(custom_id, label, form_id):
    # Read-only still renders the form's Save button, which does nothing useful in a viewer
    hide_save = "<style>#submit.form-button { display: none !important; }</style>"
    return menu("org.joget.apps.userview.lib.FormMenu", custom_id, label, formId=form_id, keyName="",
                readonly="readonly", readonlyLabel="true", showInPopupDialog="", loadDataWithKey="",
                customHeader=hide_save, customFooter="", cancelButtonLabel="", submitButtonLabel="",
                actionAfterSaved="", redirectTargetOnCancel="top", afterSavedReloadTarget="true")


def html_page(custom_id, label, html):
    return menu("org.joget.apps.userview.lib.HtmlPage", custom_id, label, content=html)


def category(key, label, menus, hidden=False):
    props = {"id": "category-" + stable_id(key), "label": label, "comment": "", "permission": plugin()}
    if hidden:
        props["hide"] = "yes"
    return {"className": "org.joget.apps.userview.model.UserviewCategory", "properties": props, "menus": menus}


def userview_json(categories, userview_id="v"):
    return {
        "className": "org.joget.apps.userview.model.Userview",
        "categories": categories,
        "properties": {"id": userview_id, "name": APP_NAME, "description": "", "logoutText": "Logout",
                       "welcomeMessage": "#date.EEE, d MMM yyyy#", "footerMessage": "Powered by Joget"},
        "setting": {"properties": {
            "userviewId": userview_id, "userviewName": APP_NAME, "userviewDescription": "",
            "tempDisablePermissionChecking": "", "noPermissionMessage": "",
            "hideThisUserviewInAppCenter": "", "userview_thumbnail": "", "userview_category": "",
            "permission": plugin("org.joget.apps.userview.lib.LoggedInUserPermission"),
            "theme": plugin("org.joget.apps.userview.lib.AjaxUniversalTheme",
                            dx8colorScheme="#e9e9e9;#FFFFFF;#AECAC7;#2C6562;#1976d2;#004ba0",
                            userImage="no", userMenu=[], shortcut=[], css="", js="", mobileViewDisabled="",
                            mobileCacheEnabled=""),
        }},
    }


GUIDE_HTML = """<h2>Open Slider Demo</h2>
<p>Every list here shows the same eight customers. Clicking a link or button opens the customer's
record in a slider instead of leaving the page. Click outside the slider to close it.</p>
<table class="table">
<tr><th>Menu</th><th>What to try</th></tr>
<tr><td><b>Single Slider</b></td><td>Click a customer name. One slider; opening another customer replaces its content.</td></tr>
<tr><td><b>Multi-tab Slider</b></td><td>Open several customers. Each gets a tab along the top of the slider. You can switch between tabs, close them, and minimize the whole slider.</td></tr>
<tr><td><b>Row Action</b></td><td>The Open button is a row action (Open Slider DataList Action), not a column formatter.</td></tr>
<tr><td><b>Top Window</b></td><td>The two lists sit in frames, as in a dashboard. With Open In = Top window the slider covers the whole page instead of one frame.</td></tr>
<tr><td><b>Manage Customers</b></td><td>Add, edit and delete customers.</td></tr>
</table>
<p>On the Top Window page, open a customer, then go to Guide or Manage Customers and back. The links should still open the slider.</p>"""


def frame(menu_id, title):
    return ('<h4>%s</h4><iframe src="#request.contextPath#/web/userview/%s/v/_/%s?embed=true" '
            'style="width:100%%;height:400px;border:1px solid #ccc;border-radius:4px;margin-bottom:20px;"></iframe>'
            % (title, APP_ID, menu_id))


def top_page_html():
    return ("<p>Each list below is in its own frame and set to <b>Open In: Top window</b>, so the slider "
            "opens over this whole page.</p>"
            + frame("top_formatter", "Column formatter (Open Slider List Formatter)")
            + frame("top_action", "Row action (Open Slider DataList Action)"))


# ---------------------------------------------------------------------------
# appDefinition.xml
# ---------------------------------------------------------------------------
def build_app_xml(forms, lists, userviews):
    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S.0 UTC")
    root = ET.Element("appDefinition")

    def add(parent, tag, text=None, **attrs):
        el = ET.SubElement(parent, tag, attrs)
        if text is not None:
            el.text = text
        return el

    add(root, "appId", APP_ID)
    add(root, "id", APP_ID)
    add(root, "version", APP_VERSION)
    add(root, "name", APP_NAME)
    add(root, "dateCreated", now, **{"class": "java.sql.Timestamp"})
    add(root, "dateModified", now, **{"class": "java.sql.Timestamp"})
    add(root, "packageDefinitionList")

    def definition(list_tag, item_tag, def_id, name, payload, extra=None):
        container = root.find(list_tag)
        if container is None:
            container = add(root, list_tag)
        item = add(container, item_tag)
        add(item, "id", def_id)
        add(item, "appId", APP_ID)
        add(item, "appVersion", APP_VERSION)
        add(item, "name", name)
        for k, v in (extra or {}).items():
            add(item, k, v)
        add(item, "json", json.dumps(payload, indent=4))
        add(item, "dateCreated", now, **{"class": "java.sql.Timestamp"})
        add(item, "dateModified", now, **{"class": "java.sql.Timestamp"})

    for form_id, name, payload in forms:
        definition("formDefinitionList", "formDefinition", form_id, name, payload, {"tableName": TABLE})
    for list_id, name, payload in lists:
        definition("datalistDefinitionList", "datalistDefinition", list_id, name, payload)
    for uv_id, name, payload in userviews:
        definition("userviewDefinitionList", "userviewDefinition", uv_id, name, payload, {"description": ""})

    add(root, "pluginDefaultPropertiesList")
    add(root, "environmentVariableList")
    add(root, "messageList")
    add(root, "createdBy", "admin")
    ET.indent(root, space="   ")
    return ET.tostring(root, encoding="unicode")


CUSTOMERS = [
    ("Ada Lovelace", "Analytical Engines Ltd", "ada@example.com", "Active",
     "Prefers email. Renewal due next quarter."),
    ("Grace Hopper", "Compiler Works", "grace@example.com", "Active", "Asked for a demo of the reports."),
    ("Alan Turing", "Bombe Systems", "alan@example.com", "Lead", "Met at the conference. Follow up this week."),
    ("Katherine Johnson", "Orbit Dynamics", "katherine@example.com", "Active", "Large account, two sites."),
    ("Edsger Dijkstra", "Semaphore Inc", "edsger@example.com", "Churned", "Left over pricing."),
    ("Margaret Hamilton", "Apollo Software", "margaret@example.com", "Lead", "Evaluating three vendors."),
    ("Linus Torvalds", "Kernel Co", "linus@example.com", "Active", "Wants an API for exports."),
    ("Barbara Liskov", "Substitution Labs", "barbara@example.com", "Lead", "Trial starts Monday."),
]


def seed_rows():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    rows = []
    for i, (name, company, email, status, notes) in enumerate(CUSTOMERS, 1):
        rows.append({
            "id": "customer-%d" % i, "dateCreated": now, "dateModified": now, "createdBy": "admin",
            "createdByName": "Admin", "modifiedBy": "admin", "modifiedByName": "Admin",
            "name": name, "company": company, "email": email, "status": status, "notes": notes})
    return rows


def main():
    customer = form_json("customer", "Customer", [
        text_field("name", "Name", mandatory=True),
        text_field("company", "Company"),
        text_field("email", "Email"),
        select_box("status", "Status", ["Lead", "Active", "Churned"]),
        text_area("notes", "Notes"),
    ])

    lists = [
        ("list_customer", "List - Customer", list_json("list_customer", "List - Customer")),
        ("list_single", "List - Single Slider",
         list_json("list_single", "List - Single Slider", slider_formatter())),
        ("list_multitab", "List - Multi-tab Slider",
         list_json("list_multitab", "List - Multi-tab Slider", slider_formatter(multi_tab=True))),
        ("list_action", "List - Row Action",
         list_json("list_action", "List - Row Action", row_actions=[slider_row_action("rowAction_0")])),
        ("list_top_formatter", "List - Top Window Formatter",
         list_json("list_top_formatter", "List - Top Window Formatter",
                   slider_formatter(width="60%", open_in="top"), page_size="5")),
        ("list_top_action", "List - Top Window Action",
         list_json("list_top_action", "List - Top Window Action",
                   row_actions=[slider_row_action("rowAction_0", width="60%", open_in="top")], page_size="5")),
    ]

    uv = userview_json([
        category("home", "<i class='fa fa-home'></i> Home", [html_page("guide", "Guide", GUIDE_HTML)]),
        category("sliders", "<i class='fa fa-columns'></i> Slider Demos", [
            datalist_menu("single", "Single Slider", "list_single"),
            datalist_menu("multitab", "Multi-tab Slider", "list_multitab"),
            datalist_menu("rowaction", "Row Action", "list_action"),
            html_page("top", "Top Window", top_page_html()),
        ]),
        category("data", "<i class='fa fa-database'></i> Data", [
            crud_menu("customers", "Manage Customers", "list_customer", "customer"),
        ]),
        category("hidden", "Hidden", [
            form_menu_readonly("customer_detail", "Customer Detail", "customer"),
            datalist_menu("top_formatter", "Top Window Formatter", "list_top_formatter"),
            datalist_menu("top_action", "Top Window Action", "list_top_action"),
        ], hidden=True),
    ])

    xml = build_app_xml(
        forms=[("customer", "Customer", customer)],
        lists=lists,
        userviews=[("v", APP_NAME, uv)],
    )

    jwa = os.path.join(HERE, "%s.jwa" % APP_NAME.replace(" ", ""))
    with zipfile.ZipFile(jwa, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("appDefinition.xml", xml)
        z.writestr("data/%s.json" % TABLE, json.dumps(seed_rows(), indent=1))
    print("wrote", jwa)


if __name__ == "__main__":
    main()
