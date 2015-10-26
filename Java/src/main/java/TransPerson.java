import lombok.Data;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by imivan on 15-10-24.
 */

@Data
public class TransPerson {
    Map<String,String> property = new HashMap<String, String>();
    TransPerson put(String key,String value) {
        property.put(key,value);
        return this;
    }
}
