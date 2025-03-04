# 📌 Last-Minute Budget Trip Planner using CrewAI

## Problem Statement
Planning a last-minute budget-friendly trip requires **real-time data** on flights, hotels, weather, and attractions. Manual trip planning is **time-consuming** and **error-prone**, especially when trying to fit multiple constraints like budget limits, historical site preferences, and proximity to public transport. This project aims to automate the entire trip planning process using **AI agents** that work collaboratively.

## Objective
To create an **AI-powered Trip Advisor System** that automates the process of planning a 3-day budget-friendly historical trip to London under $1500. The system will provide:
- Historical site recommendations
- Real-time weather updates
- Budget-friendly flights and hotels
- A 3-day detailed itinerary

## Tech Stack & Packages Used
| Package            | Purpose                          |
|----------------|--------------------------------|
| `CrewAI`       | Agent-based automation framework |
| `SerperDevTool` | Real-time web search for flights, hotels, and weather |
| `Google Gemini API` | Language model for AI agents |
| `Python`       | Core programming language |
| `os`           | Environment variable management |
| `crewai_tools` | Tool library for external API integration |
| `Streamlit`    | Web application framework for interactive UI |

## Project Architecture
The system uses **three intelligent agents** working in collaboration:

1. **Travel Researcher Agent**
   - Gathers historical sites, hotels, and weather information.
   - Fetches real-time data using SerperDevTool.

2. **Budget Planner Agent**
   - Finds budget-friendly flights and hotel options.
   - Calculates estimated daily expenses to ensure the budget cap is maintained.

3. **Itinerary Planner Agent**
   - Combines the research and budget information.
   - Designs a 3-day trip itinerary, considering weather and transport recommendations.

## How It Works
1. The system takes two inputs: **destination** and **budget**.
2. The **Travel Researcher Agent** fetches real-time data for historical sites, weather updates, and hotels.
3. The **Budget Planner Agent** calculates total expenses (flights, hotels, food, and transport) while staying under the $1500 budget.
4. The **Itinerary Planner Agent** generates a detailed **3-day plan**.
5. The agents execute their tasks **sequentially** using CrewAI's workflow process.

## Streamlit Web Application
A **Streamlit web application** interface is built to make the project more interactive and user-friendly.

### How to Use the App
1. Enter the **destination**.
2. Input the **budget**.
3. Click **Generate Plan**.
4. The app will display:
   - Top Historical Sites
   - Real-time Weather Report
   - Budget Breakdown
   - 3-Day Itinerary

### Install Required Libraries
```bash
pip install crewai crewai_tools google-generativeai streamlit
```

### Streamlit App Code
```python
import streamlit as st
import os
from crewai import Agent, Task, Crew, Process, LLM
from crewai_tools import SerperDevTool

# Set API keys
os.environ["GOOGLE_API_KEY"] = "your_gemini_api_key"
os.environ["SERPER_API_KEY"] = "your_serper_api_key"

# Initialize search tool
search_tool = SerperDevTool()

# Define LLM
llm = LLM(model="gemini/gemini-1.5-flash", temperature=0.5, api_key=os.environ["GOOGLE_API_KEY"])

st.title("AI Trip Planner")

destination = st.text_input("Enter Destination:")
budget = st.number_input("Enter Budget ($):", min_value=500, max_value=5000, step=100)

if st.button("Generate Plan"):
    if destination and budget:
        researcher = Agent(role="Travel Researcher", goal=f"Find historical sites and weather for {destination}.", llm=llm, tools=[search_tool])
        budget_planner = Agent(role="Budget Planner", goal=f"Plan budget under ${budget} for {destination}.", llm=llm, tools=[search_tool])
        itinerary_planner = Agent(role="Itinerary Planner", goal=f"Create itinerary for {destination} under ${budget}.", llm=llm, tools=[search_tool])

        research_task = Task(description="Research historical sites and weather.", agent=researcher)
        budget_task = Task(description="Plan budget.", agent=budget_planner)
        itinerary_task = Task(description="Create itinerary.", agent=itinerary_planner)

        crew = Crew(agents=[researcher, budget_planner, itinerary_planner], tasks=[research_task, budget_task, itinerary_task], process=Process.sequential)
        result = crew.kickoff(inputs={'destination': destination, 'budget': str(budget)})
        st.success("Trip Plan Generated Successfully!")
        st.text(result)
    else:
        st.warning("Please enter both Destination and Budget.")
```

### Run the App
```bash
streamlit run trip_planner_app.py
```

## Results & Output
The system will generate:
- Top 5 historical sites in London
- Real-time weather forecast
- 3 hotel options near public transport
- Full budget breakdown (Flights, Hotel, Food, Transport)
- 3-day itinerary plan with time slots and activities

## Future Enhancements
- Add custom trip preferences (Adventure, Shopping, Nature)
- Support for multiple destinations
- Generate flight ticket booking links
- Integration with Google Maps APIs

## Conclusion
This **AI-powered Trip Planner** automates the entire travel planning process with minimal user input. The system ensures the trip stays under budget while providing a **seamless itinerary** focused on historical attractions. This solution saves **time**, **effort**, and **money** for travelers.

## Folder Structure
```bash
├── trip_planner.py        # Main Code
├── trip_planner_app.py    # Streamlit Application
├── README.md             # Project Documentation
└── requirements.txt       # Dependencies
```

---
Feel free to contribute and enhance the project! ⭐

