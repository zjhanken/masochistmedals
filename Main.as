[Setting hidden]
void Main() {
    startnew(UpdateTimes);
}

const string WindowTitle = "MASOCHIST MEDAL";
UI::Texture@ medalImage = UI::LoadTexture("assets/masmedal.png");
bool windowVisible = true;
bool ShowWindow = true;
bool updating = false;
array<int> pbTimes(25, 1);
array<int> mapPos(25,1);
// Array to store target times
array<int> targetTimes = {
    27435, 24939, 28421, 25648, 26219, 29798, 32145, 22352, 25923, 30100,
    38049, 37683, 34216, 32144, 38666, 49233, 51736, 36279, 63800, 33637,
    48001, 71865, 54467, 48281, 88385
};

// Array to store the player's times on each map (initially zero)
array<float> playerTimes(25, 0.0);

// Flag to indicate whether times are being loaded
bool loadingTimes = true;

void RenderMenu() {
    if (UI::MenuItem(WindowTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

// Main Render Function
void RenderInterface() {
    if (!windowVisible) return;
    mapPos[0]=15;
    if (!ShowWindow) return;

    if (UI::Begin(WindowTitle, ShowWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize)) {
        UI::SetWindowSize(vec2(500, 610));
    
        // Display the list of target times and user times
        UpdateText();

        // Add a reload button to fetch the updated times
        if (UI::Button("Reload")) {
            updating = true;
            startnew(UpdateTimes);
        }
        if(!updating) {
            UpdateText();
            updating = true;
        }

        UI::End();
    }
}

// Function to update player times
void UpdateTimes() {
    startnew(API::GetRank);
}


void UpdateText() {
    for (int i = 0; i < targetTimes.Length; i++) {
        string mapName = "Map " + (i + 1);

        // Format the player's time
        string userTimeText = (pbTimes[i] > 0) ? FormatTime(pbTimes[i]) : "No time recorded";

        // Format the target time
        string targetTimeText = FormatTime(int(targetTimes[i]));  // Convert seconds to milliseconds for consistency

        // Color the text based on whether the player beats the target time
        vec4 col;
        if (pbTimes[i] > 0 && (pbTimes[i]) <= targetTimes[i]) {
            col = vec4(0.0, 1.0, 0.0, 1.0);  // Green if beaten
        } else {
            col = vec4(1.0, 0.0, 0.0, 1.0);  // Red if not beaten or no time
        }

        // Apply text color and display times
        UI::PushStyleColor(UI::Col::Text, col);
        UI::Text(mapName + ": Your Time: " + userTimeText + " / Target Time: " + targetTimeText + " / Target Position: " + mapPos[i]);
        UI::PopStyleColor();

        // Show the medal image if the player beats the target time
        if (pbTimes[i] <= targetTimes[i] && pbTimes[i] > 0) {
            UI::SameLine();  // Align the image to the right of the text
            UI::Image(medalImage, vec2(30, 16));  // Display the medal image (30x16 px)
        }
    }
}

// Function to format time correctly
string FormatTime(int timeInMilliseconds) {
    float timeInSeconds = timeInMilliseconds / 1000.0;
    
    if (timeInSeconds < 60) {
        // Return the time as seconds with 3 decimal places for times under 60s
        return Text::Format("%.3f", timeInSeconds) + "s";
    } else {
        // Format for times 60 seconds or more: "minutes:seconds.milliseconds"
        int minutes = int(timeInSeconds / 60);
        float remainingSeconds = timeInSeconds - (minutes * 60);
        return "" + minutes + ":" + Text::Format("%06.3f", remainingSeconds);  // Add leading zero to seconds if necessary
    }
}

