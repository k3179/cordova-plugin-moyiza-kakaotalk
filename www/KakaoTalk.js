var exec = require('cordova/exec');

exports.share = function (arg0, success, error) {
    exec(success, error, 'KakaoTalk', 'share', [arg0]);
};
exports.shareStory = function (arg0, success, error) {
    exec(success, error, 'KakaoTalk', 'shareStory', [arg0]);
};