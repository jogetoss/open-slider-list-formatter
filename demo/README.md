# Demo app

A ready-made Joget app that exercises both plugins in this repo, the Open Slider List Formatter and the Open Slider DataList Action: eight sample customers, each opening in a slider.

Requires Joget DX 9 (the app uses the Advanced Form Row Datalist Binder and the CRUD menu).

## Set up

1. Install the plugin jar (`mvn package`, then upload `target/open-slider-list-formatter-*.jar` under Manage Plugins).
2. In App Center choose **Design New App > Import App** and upload [`OpenSliderDemo.jwa`](OpenSliderDemo.jwa). Leave the data import on so the sample customers are loaded.
3. Publish the imported version, then open the app's **Guide** menu.

To regenerate the file after editing the script:

```bash
python3 demo/build_demo_app.py
```

## What it shows

| Feature | Menu |
|---|---|
| Formatter on the Name column, one slider that is reused for each click | Single Slider |
| Multi Tab: each customer gets a tab, with tab name taken from the Name column | Multi-tab Slider |
| The same slider as a row action instead of a column formatter | Row Action |
| Open In = Top window for a formatter and for an action, both in frames | Top Window |
| Adding and editing the customers | Manage Customers |

## How it is wired

- **Form `customer`** (table `osd_customer`) holds the data. The bundled rows are in `data/osd_customer.json` inside the `.jwa`.
- **Datalists** all read that form with the Advanced Form Row Datalist Binder. `list_single`, `list_multitab` and `list_top_formatter` put the formatter on the Name column, and `list_action` and `list_top_action` add the action as a row action. `list_customer` has no slider and backs Manage Customers.
- **Form menu `customer_detail`** is what the slider opens, as a read-only view. The plugins are given `customer_detail?embed=true`, plus `&id=<row id>`, so it shows without the userview chrome. A small style in its Custom Header hides the Save button, which a read-only Form menu still renders.
- **Top Window** is an HTML page with two iframes onto hidden menus `top_formatter` and `top_action`, the way a dashboard portlet frames a list.
- The app does not embed the plugin jar. Install the plugin separately.
