# -*- coding: utf-8 -*-
"""
@author: Omkar Nallagoni
"""




import numpy as np
import pickle
import pandas as pd
import streamlit as st 

from PIL import Image


pickle_in = open("wine_data.pkl","rb")
classifier=pickle.load(pickle_in)


def welcome():
    return "Welcome All"


def predict_note_authentication(citric_acid, residual_sugar	,chlorides):
   
    prediction=classifier.predict([[citric_acid,residual_sugar,chlorides]])
    print(prediction)
    return prediction



def main():
    st.title("wine qualit")
    html_temp = """
    <div style="background-color:tomato;padding:10px">
    <h2 style="color:white;text-align:center;">Streamlit WINE QUALIT ML App </h2>
    </div>
    """
    st.markdown(html_temp,unsafe_allow_html=True)
    citric_acid = st.text_input("Citric_acid","Type Here")
    residual_sugar = st.text_input("residual_sugar","Type Here")
    chlorides = st.text_input("chlorides","Type Here")
    
    result=""
    if st.button("Predict"):
        result=predict_note_authentication(eval(citric_acid), 
                                           eval(residual_sugar), 
                                           eval(chlorides)
                                        
                                          )
    st.success('The output is {}'.format(result))
    if st.button("About"):
        st.text("Lets LEarn")
        st.text("This is about wine qulaity red data")

if __name__=='__main__':
    main()
    
    
    