#%%writefile app.py
import os
import streamlit as st
from crewai import Agent, Task, Crew, Process, LLM
from crewai_tools import SerperDevTool

# --- Initialize search tool ---
search_tool = SerperDevTool()

# --- Define AI Model ---
llm = LLM(model="gemini/gemini-1.5-flash",
          verbose=True,
          temperature=0.5,
          api_key=os.environ.get("", ""))

# --- Streamlit UI ---
st.title("🌍 AI-Powered Travel Planner")
st.markdown("**Plan your perfect trip with AI-powered insights!**")

destination = st.text_input("📍 Enter Destination:")
budget = st.text_input("💰 Enter Budget (INR):")

# --- Function to create AI Agents ---
def create_agents(destination, budget):
    researcher = Agent(
        role="Travel Researcher",
        goal=f"Find historical sites, public transport hotels, and real-time weather for {destination}.",
        backstory="You are an expert travel researcher, providing up-to-date information about history-focused trips.",
        verbose=True,
        memory=True,
        llm=llm,
        tools=[search_tool]
    )

    budget_planner = Agent(
        role="Budget Planner",
        goal=f"Find budget flights, hotels, and activities within {budget} for {destination}.",
        backstory="You are a skilled budget analyst ensuring trips fit within financial constraints.",
        verbose=True,
        memory=True,
        llm=llm,
        tools=[search_tool]
    )

    itinerary_planner = Agent(
        role="Itinerary Planner",
        goal=f"Create a 3-day itinerary for {destination}, ensuring all historical sites are covered under {budget}.",
        backstory="You are an expert in trip planning, ensuring travelers get the best experience within their budget.",
        verbose=True,
        memory=True,
        llm=llm,
        tools=[search_tool]
    )

    return researcher, budget_planner, itinerary_planner

# --- Generate Travel Plan Button ---
if st.button("🎯 Generate Travel Plan"):
    if not destination or not budget:
        st.error("⚠️ Please enter both a destination and budget.")
    else:
        st.info("⏳ Generating your AI-powered travel plan...")

        # Create AI Agents
        researcher, budget_planner, itinerary_planner = create_agents(destination, budget)

        # Define AI Tasks
        research_task = Task(
            description=f"Find the best historical sites, weather forecast, and public transport hotels for {destination}.",
            expected_output="✅ A list of top historical sites, a real-time weather update, and 3 hotel options near public transport.",
            agent=researcher
        )

        budget_task = Task(
            description=f"Find budget flights, hotel options, and daily costs for {destination} within {budget}.",
            expected_output=f"✅ A full cost breakdown (flights, hotel, food, attractions) ensuring a {budget} budget is maintained.",
            agent=budget_planner
        )

        itinerary_task = Task(
            description=f"Plan a 3-day itinerary for {destination} under {budget}.",
            expected_output="✅ A detailed 3-day plan, considering weather and budget constraints, with transport recommendations.",
            agent=itinerary_planner
        )

        # --- Create Crew ---
        crew = Crew(
            agents=[researcher, budget_planner, itinerary_planner],
            tasks=[research_task, budget_task, itinerary_task],
            process=Process.sequential
        )

        # --- Run AI Agents ---
        responses = crew.kickoff(inputs={'destination': destination, 'budget': budget})

        # --- Display Results ---
        st.success("✅ Travel Plan Generated!")

        # Clean and display the output
        for agent_name, response in zip(["Travel Researcher", "Budget Planner", "Itinerary Planner"], responses):
            st.subheader(f"📌 {agent_name} Findings")

            # Ensure response is properly formatted
            if isinstance(response, tuple) and len(response) > 1:
                clean_response = response[1]  # Extract the actual text from tuple
            else:
                clean_response = response

            st.write(clean_response if clean_response else "No response available.")


st.markdown("🌍 *Enjoy your AI-powered trip planning!* 🚀")
