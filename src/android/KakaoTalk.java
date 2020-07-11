package com.moyiza.plugin.kakaotalk;

import android.app.Activity;
import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import com.kakao.kakaolink.internal.KakaoTalkLinkProtocol;
import com.kakao.kakaolink.v2.KakaoLinkService;
import com.kakao.kakaolink.v2.KakaoLinkResponse;
import com.kakao.message.template.*;
import com.kakao.network.callback.*;
import com.kakao.network.ErrorResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
/**
 * This class echoes a string called from JavaScript.
 */
public class KakaoTalk extends CordovaPlugin {

	//private static volatile Activity currentActivity;

	
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        try {
            //KakaoSDK.init(new KakaoSDKAdapter());
        } catch (Exception e) {

        }
    }
	
	

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("share")) {
            this.share(args, callbackContext);
            return true;
        }else if(action.equals("shareStory")){
            this.shareStory(args, callbackContext);
            return true;
		}
        return false;
    }

    private void share(JSONArray args, CallbackContext callbackContext) {

			final Activity activity = this.cordova.getActivity();
			// run in background
			cordova.getThreadPool().execute(new Runnable() {

				@Override
				public void run() {


					try {

						final JSONObject parameters = args.getJSONObject(0);

						String	title	=	parameters.getString("title");
						String	link	=	parameters.getString("link");
						String	appLink	=	parameters.getString("appLink");
						String	desc	=	parameters.getString("desc");

						if(parameters.has("thumb")){
							String	thumb	=	parameters.getString("thumb");
							FeedTemplate params = FeedTemplate
									.newBuilder(
										ContentObject.newBuilder(
											title,
											thumb,
											LinkObject.newBuilder().setWebUrl(link).setMobileWebUrl(link).build()
										)
										.setDescrption(desc)
										.build()
									)
									
									.addButton(new ButtonObject("웹에서 보기", LinkObject.newBuilder().setWebUrl(link).setMobileWebUrl(link).build()))
									//.addButton(new ButtonObject("앱에서 보기", LinkObject.newBuilder().setWebUrl(appLink).setMobileWebUrl(appLink).build()))
									
									.build();
							KakaoLinkService.getInstance().sendDefault(activity, params, new ResponseCallback<KakaoLinkResponse>() {
								public void onFailure(ErrorResult errorResult) {
									callbackContext.error(errorResult.getErrorMessage());
								}
								public void onSuccess(KakaoLinkResponse result) {
									// 템플릿 밸리데이션과 쿼터 체크가 성공적으로 끝남. 톡에서 정상적으로 보내졌는지 보장은 할 수 없다. 전송 성공 유무는 서버콜백 기능을 이용하여야 한다.
									//callbackContext.success("success send");
								}
							});
						}else{
							TextTemplate params = TextTemplate
									.newBuilder(
										title,
										LinkObject.newBuilder().setWebUrl(link).setMobileWebUrl(link).build()
									)
									
									.addButton(new ButtonObject("웹에서 보기", LinkObject.newBuilder().setWebUrl(link).setMobileWebUrl(link).build()))
									//.addButton(new ButtonObject("앱에서 보기", LinkObject.newBuilder().setWebUrl(appLink).setMobileWebUrl(appLink).build()))
									
									.build();
							KakaoLinkService.getInstance().sendDefault(activity, params, new ResponseCallback<KakaoLinkResponse>() {
								public void onFailure(ErrorResult errorResult) {
									callbackContext.error(errorResult.getErrorMessage());
								}
								public void onSuccess(KakaoLinkResponse result) {
									// 템플릿 밸리데이션과 쿼터 체크가 성공적으로 끝남. 톡에서 정상적으로 보내졌는지 보장은 할 수 없다. 전송 성공 유무는 서버콜백 기능을 이용하여야 한다.
									//callbackContext.success("success send");
								}
							});
						}



					}catch (Exception e) {
						e.printStackTrace();
						callbackContext.error("공유시 오류가 발생하였습니다.");
					}

				}

			}
		);

    }

    private void shareStory(JSONArray args, CallbackContext callbackContext) {

			final Activity activity = this.cordova.getActivity();

			// run in background
			cordova.getThreadPool().execute(new Runnable() {

				@Override
				public void run() {
					try {

						final JSONObject parameters = args.getJSONObject(0);

						String	appid	=	parameters.getString("appid");
						String	appver	=	parameters.getString("appver");
						String	appname	=	parameters.getString("appname");

						String	title	=	parameters.getString("title");
						String	desc	=	parameters.getString("desc");
						String	link	=	parameters.getString("link");

						Map<String, Object> urlInfoAndroid = new Hashtable<String, Object>(1);
						urlInfoAndroid.put("title", title);
						urlInfoAndroid.put("desc", desc);
						if(parameters.has("thumb")){
							String	thumb	=	parameters.getString("thumb");
							urlInfoAndroid.put("imageurl", thumb);
						}
						urlInfoAndroid.put("type", "article");
						StoryLink storyLink = StoryLink.getLink(activity);
						// check, intent is available.
						if (!storyLink.isAvailableIntent()) {
							callbackContext.error("카카오스토리가 설치되어있지 않습니다.");
							return;
						}
						storyLink.openKakaoLink(activity,
								link,
								appid,
								appver,
								appname,
								"UTF-8",
								urlInfoAndroid);

					}catch (Exception e) {
						e.printStackTrace();
						callbackContext.error("공유시 오류가 발생하였습니다.");
					}

				}
			}
		);
    }
}