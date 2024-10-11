
namespace API {
    const string tm_maps_endpoint = "https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/map";
    Json::Value req_body2 = Json::Object();

    void GetRank() {

        Json::Value req_body = Json::Object();
        req_body["maps"] = Json::Array();
        auto reqCampaign = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + "/api/token/campaign/official?length=1&offset=0");
        reqCampaign.Start();
        while (!reqCampaign.Finished()) {
            yield();
        }
        auto resCampaign = Json::Parse(reqCampaign.String());
        auto currentCampaign = resCampaign["campaignList"][0];
        string currentCampaignGroupId = currentCampaign["leaderboardGroupUid"];
        auto mapList = currentCampaign["playlist"];

        for (uint i = 0; i < 25; ++i) {
            Json::Value req_map = Json::Object();
            req_map["groupUid"] = "Personal_Best";
            req_map["mapUid"] = mapList[i]["mapUid"];
            req_body["maps"].Add(req_map);
        }
        req_body2=req_body;
        

        string req_url = "https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/map?";
        for(uint i=0;i < 25; ++i) {
            string mapid = mapList[i]["mapUid"];
            req_url+="scores["+mapid+"]="+targetTimes[i]+"&";
        }
        Net::HttpRequest@ request = NadeoServices::Post("NadeoLiveServices", req_url, Json::Write(req_body2));
        request.Start();
        while (!request.Finished()) yield();
        Json::Value res2 = Json::Parse(request.String());
        for (int i = 0; i < 25; ++i) {
            Json::Value tester = res2[i];
            mapPos[i]=res2[i]["zones"][0]["ranking"]["position"];
        }
        


        Net::HttpRequest@ req = NadeoServices::Post("NadeoLiveServices", tm_maps_endpoint, Json::Write(req_body));
        req.Start();
        while (!req.Finished()) yield();
        Json::Value res = Json::Parse(req.String());


        // this result is in the same order as the campaign maps, and contains
        // either the full set or a subset
        uint ci = 0;  // index for traversing through campaign maps
        for (uint i = 0; i < 25; ++i) {
            Json::Value res_map = res[i];
            string uid = res_map["mapUid"];
            uint pb_time = res_map["score"];
            while (mapList[ci]["mapUid"] != uid) {
                if (++ci >= 25) ci = 0;  // this should never happen, but just to be safe
            }
            pbTimes[i] = pb_time;
            
        }
        updating = false;
    }

}
