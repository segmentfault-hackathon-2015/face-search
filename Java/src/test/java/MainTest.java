import com.facepp.error.FaceppParseException;
import com.facepp.http.HttpRequests;
import com.facepp.http.PostParameters;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by imivan on 15-10-24.
 */
public class MainTest {

    static HttpRequests httpRequests = new HttpRequests("bbfea187ed64a03ee9d4ff2a425c5edf", "f8A_isaIyIwTCKEnUrCoou5llzfb3kp4 ", true, true);

    public static void main(String[] args) throws Exception {
//                System.out.println(httpRequests.recognitionIdentify(
//                new PostParameters().setGroupName("group_test")
//                        .setImg(new File("/home/imivan/IMG_20151024_155257.jpg"))
//                        ));
//        httpRequests.personCreate(new PostParameters().setPersonName("wangzefeng"));
////
//        ArrayList<String> personList = new ArrayList<String>();
//        for (int i = 0; i < result.getJSONArray("face").length(); ++i)
//            personList.add("wangzefeng");
//
//        new PostParameters().setGroupName("group_test").setPersonName(personList).getMultiPart().writeTo(System.out);
//        System.out.println(httpRequests.groupAddPerson(new PostParameters().setGroupName("group_test").setPersonName(personList)));
//

        JSONObject result = httpRequests.detectionDetect(new PostParameters().setImg(new File("/home/imivan/下载/1952000216.jpg")));
//
        //添加一个人
        System.out.println(httpRequests.personCreate(new PostParameters().setPersonName("meizi")));

        //向一个人添加一张脸
        System.out.println(httpRequests.personAddFace(new PostParameters().setPersonName("meizi").setFaceId(
                result.getJSONArray("face").getJSONObject(0).getString("face_id"))));

        System.out.println(httpRequests.groupAddPerson(new PostParameters().setGroupName("group_test").setPersonName("meizi")));
        JSONObject syncRet = httpRequests.trainIdentify(new PostParameters().setGroupName("group_test"));
        System.out.println(syncRet);



    }
}
