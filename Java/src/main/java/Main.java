import com.facepp.http.HttpRequests;
import com.github.kevinsawicki.http.HttpRequest;
import com.google.gson.Gson;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.*;

import static spark.Spark.get;
import static spark.Spark.post;

/**
 * Created by imivan on 15-10-24.
 */
public class Main {

    static Map<String,List<String>> comments = new HashMap<>();
    static Gson gson = new Gson();
    static HttpRequests httpRequests = new HttpRequests("bbfea187ed64a03ee9d4ff2a425c5edf", "f8A_isaIyIwTCKEnUrCoou5llzfb3kp4 ", true, true);

    public static void main(String[] args) throws Exception {

        List<String> wangzefeng = new ArrayList<>();
        wangzefeng.add("大帅比");
        wangzefeng.add("他坐我隔壁!!");
        comments.put("wangzefeng",wangzefeng);


        get("/person_info/:name", (req, resp) -> {
            String num = req.params(":name");
            Map<String, String> person = trans(num);
            System.out.println(gson.toJson(person));
            return person;
        }, gson::toJson);

        get("/person_comment/:name",(req,resp) -> {
            String num = req.params(":name");
            List<String> comment_list = comments.get(num);
            if (comment_list==null) comment_list = new ArrayList<String>();
            return comment_list;
        },gson::toJson);

        post("/person_comment/:name",(req, resp) -> {
            String num = req.params(":name");
            List<String> comment_list = comments.get(num);
            if (comment_list==null) comment_list = new ArrayList<String>();
            comment_list.add(req.body());
            resp.status(201);
            return "";
        });

    }

    static Map<String,String> trans(String person_name) throws FileNotFoundException {
        Map<String,String> result = new HashMap<>();
        if (person_name.equals("wangzefeng")) {
            result.put("姓名","王泽锋");
            result.put("公司","平安科技");
            result.put("手机","手机13510278542");
            result.put("性别","汉子");
            result.put("状态","单身");
            return result;
        }

        if (person_name.equals("liweitao")) {
            result.put("姓名","李伟涛");
            result.put("手机","手机13714571620");
            result.put("性别","汉子");
            result.put("爱好","爱好打篮球");
            return result;
        }

        if (person_name.equals("sunyucong")) {
            result.put("姓名","孙宇聪");
            result.put("公司","coding.net");
            result.put("职位","CTO");
            return result;
        }


        if (person_name.equals("qining")) {
            result.put("姓名","祁宁");
            result.put("公司","segmentfault");
            result.put("职位","CTO");
            result.put("描述","技术大牛");
            return result;
        }

        if (person_name.equals("huche")) {
            result.put("姓名","胡澈");
            result.put("公司","勾搭科技");
            result.put("职位","CTO");
            return result;
        }

        if (person_name.equals("meizi")) {
            result.put("姓名","萌妹子");
            result.put("微信号","xiaojiehappy1208");
            result.put("公司","segmentfault");
            return result;
        }



        String person_json = new Scanner(new FileInputStream("/home/imivan/school_json/127.0.0.1:8000/" + person_name + ".json")).nextLine();

        FilePerson person = gson.fromJson(person_json, FilePerson.class);

        if (person==null) return result;
        result
//                .put("身份证号", person.getIDNum())
                .put("班级", person.getClazz());
//        result.put("方向", person.getField());
        result.put("专业", person.getMajor());
        result.put("姓名", person.getName());
//        result.put("学号", person.getNum());
//        result.put("状态", person.getState());
        if ((person.getIDNum().charAt(person.getIDNum().length()-2)-'0')%2==0) {
            result.put("性别","妹子");
        } else {
            result.put("性别","汉子");
        }
        result.put("生日",Integer.valueOf(person.getIDNum().substring(10,12))+"月"+Integer.valueOf(person.getIDNum().substring(12,14))+"日");
        result.put("年龄","年龄"+(2015-Integer.valueOf(person.getIDNum().substring(6,10))));
        try {
            String JSONBody = HttpRequest.get("http://apis.baidu.com/apistore/idservice/id", true, "id", "").header("apikey", "f7acdb83732229dfc76297ed4ec14d42").body();
            result.put("家乡",gson.fromJson(JSONBody,AddressJSON.class).getRetData().getAddress());
        }catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}
class AddressJSON {

    /**
     * errNum : 0
     * retMsg : success
     * retData : {"address":"广东省江门市恩平市","sex":"M","birthday":"1995-07-15"}
     */

    private int errNum;
    private String retMsg;
    /**
     * address : 广东省江门市恩平市
     * sex : M
     * birthday : 1995-07-15
     */

    private RetDataEntity retData;

    public void setErrNum(int errNum) {
        this.errNum = errNum;
    }

    public void setRetMsg(String retMsg) {
        this.retMsg = retMsg;
    }

    public void setRetData(RetDataEntity retData) {
        this.retData = retData;
    }

    public int getErrNum() {
        return errNum;
    }

    public String getRetMsg() {
        return retMsg;
    }

    public RetDataEntity getRetData() {
        return retData;
    }

    public static class RetDataEntity {
        private String address;
        private String sex;
        private String birthday;

        public void setAddress(String address) {
            this.address = address;
        }

        public void setSex(String sex) {
            this.sex = sex;
        }

        public void setBirthday(String birthday) {
            this.birthday = birthday;
        }

        public String getAddress() {
            return address;
        }

        public String getSex() {
            return sex;
        }

        public String getBirthday() {
            return birthday;
        }
    }
}
