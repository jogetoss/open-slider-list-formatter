package org.joget.marketplace;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class OpenSliderListFormatterTest {

    @Test
    public void escapesSliderMarkupAsAJsonString() {
        assertEquals("\"\\u003cdiv a=\\\"1\\\">x\\\\y\\n\\u003c/div>\"",
                OpenSliderListFormatter.jsonString("<div a=\"1\">x\\y\n</div>"));
    }

    @Test
    public void holderCannotBeClosedEarlyByTheMarkup() {
        String holder = OpenSliderListFormatter.topSliderHolder("t1", "<script>var a = 1;</script><!-- c -->");
        assertTrue(holder.startsWith("<script type=\"application/json\" id=\"t1\">"));
        //the only "</script" is the holder's own closing tag
        assertEquals(holder.indexOf("</script"), holder.lastIndexOf("</script"));
        assertTrue(holder.endsWith("</script>"));
    }
}
