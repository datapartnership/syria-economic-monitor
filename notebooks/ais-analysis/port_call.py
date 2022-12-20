#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import datetime
import geopandas as gp
from datetime import timedelta


def substract_seconds(x, y):
    return pd.to_datetime(x, format='%Y-%m-%d %H:%M:%S') - pd.Timedelta(y, unit='s')


def passing_by(df):
    if (df["turn_around_time"] < 3) and (0 < np.abs(df['heading-diff']) < 75):
        return 1
    elif (df["turn_around_time"] < 3) and (np.abs(df['heading-diff']) >= 75):
        return 2
    else:
        return 3

def cumsum_rows(df):
    mask = pd.isna(df).astype(bool)
    # compute cumsum across rows fillna with ffill
    cumulative = df.cumsum(1).fillna(method='ffill', axis=1).fillna(0)
    # get the values of cumulative where nan is True use the same method
    restart = cumulative[mask].fillna(method='ffill', axis=1).fillna(0)
    # set the result
    result = (cumulative - restart)
    result[mask] = np.nan
    return result

def week_format(date0,date1,date_format):
    d1 = datetime.datetime.strptime(str(date0), date_format).date()
    d2 = datetime.datetime.strptime(str(date1), date_format).date()
    d = d1
    step = datetime.timedelta(days=90)

    list_weeks = []
    while d < d2:
        list_weeks.append(d.strftime(date_format))
        d += step
    list_weeks.append(str(date1))
    return list_weeks


def get_list_dates(date0,date1):
    #### get the list of dates to merge later on
    datetime_object1 = datetime.datetime.strptime(date0, '%Y-%m-%d')
    datetime_object2 = datetime.datetime.strptime(date1, '%Y-%m-%d')

    datetime_diff = (datetime_object2-datetime_object1).days

    list_dates = pd.date_range(str(date0), periods=datetime_diff+1, freq='1D')
    list_dates_df = pd.DataFrame({'Date':list_dates.date.astype(str)})
    list_dates_df = list_dates_df.set_index('Date')

    return list_dates_df

def create_port_calls(data, date0, date1, port, country):
    ####
        #data: should be a dataframe (Pandas Dataframe)
        #date0: should be the starting date of data extraction (string, e.g. '01-01-2020')
        #date1: should be the end date of data extraction (string, e.g. '01-01-2020')
        #port_name: name of port (string)
        #country: name of country (string)
    ###
    data = data.loc[~data['nav_status'].isin(['At Anchor'])]
    data = data.loc[~data.mmsi.isna()]

    ### set date and time
    data[['Date','Time']] = data.dt_pos_utc.str.split(' ',expand=True)
    data['hour'] = pd.to_datetime(data['Time'], format='%H:%M:%S',errors = 'coerce').dt.hour
    data['dtg'] = pd.to_datetime(data['Date'] + ' ' + data['Time'])

    ### sort
    data = data.sort_values(by=['dtg'])
    data_new_subset = data[['mmsi','vessel_type','vessel_type_code','draught','length','width','longitude','latitude','Date','Time','dtg','hour','nav_status','heading','vessel_type_main','vessel_type_sub']]

    ### get per day the first and last record per vessel
    first_day = data_new_subset.drop_duplicates(subset = ['mmsi','Date'],keep='first')
    last_day = data_new_subset.drop_duplicates(subset = ['mmsi','Date'],keep='last')

    #### get the list of dates to merge later on
    list_dates_df = get_list_dates(date0,date1)

    ### First day data processing
    merged_time_series_first_select_1  = first_day[['mmsi','Date','dtg']].copy()
    merged_time_series_first_select_2  = first_day[['mmsi','vessel_type','Date','dtg','length','width','draught','heading','vessel_type_main','vessel_type_sub']].copy()
    merged_time_series_first_select_2['Date'] = merged_time_series_first_select_2['Date'].astype(str)
    merged_time_series_first_select_2.rename(columns={'Date':'date-entry', 'draught':'draught-in','heading':'heading-in'}, inplace = True)

    ### Last day data processing
    merged_time_series_last_select_1  = last_day[['mmsi','Date','dtg']].copy()
    merged_time_series_last_select_2  = last_day[['mmsi','Date','dtg','draught','heading']].copy()

    #### add full date list per mmsi
    merged_time_series_first_new = merged_time_series_first_select_1.set_index(['mmsi','Date']).unstack(level =0)
    merged_time_series_first_new = pd.concat([merged_time_series_first_new, list_dates_df], axis=1)
    merged_time_series_first_new.index.name = 'Date'
    merged_time_series_first_new = merged_time_series_first_new.stack().unstack(level = 0)

    #### add full date list per mmsi
    merged_time_series_last_new = merged_time_series_last_select_1.set_index(['mmsi','Date']).unstack(level = 0)
    merged_time_series_last_new = pd.concat([merged_time_series_last_new,list_dates_df], axis=1)
    merged_time_series_last_new.index.name = 'Date'
    merged_time_series_last_new = merged_time_series_last_new.stack().unstack(level = 0)

    ### convert to numeric value to do substraction and then convert back to number of hours
    t2 = merged_time_series_first_new.astype('datetime64').astype(int).astype(float)
    t1 = merged_time_series_last_new.astype('datetime64').astype(int).astype(float)
    time_diff = (t1['dtg']-t2['dtg'])/(3600*1000*1000*1000)
    time_diff = time_diff.replace(0,np.nan)

    ### derive the port calls and time between coming in and out
    time_diff_new = cumsum_rows(time_diff)
    time_diff_new.replace(np.nan,0, inplace = True)
    time_diff_new = time_diff_new.diff(axis = 1)
    time_diff_new = time_diff_new[time_diff_new < 0]
    cols = time_diff_new.columns[:-1]
    time_diff_new.drop(time_diff_new.columns[0],axis=1,inplace=True)
    time_diff_new.columns = cols
    time_diff_new = time_diff_new * -1
    time_diff_new = time_diff_new.mask(time_diff_new < 3)


    ### get the turnaround time
    turn_around_time = time_diff_new.unstack().dropna().reset_index(level = ['mmsi','Date'])
    turn_around_time = pd.merge(turn_around_time, merged_time_series_last_select_2, on=['Date','mmsi'])
    turn_around_time.rename(columns={"draught": "draught-out","dtg": "datetime-leave", 0: "turn_around_time", 'Date': 'date-leave','heading':'heading-out'}, inplace = True)

    turn_around_time['seconds'] = turn_around_time['turn_around_time']*3600
    turn_around_time['datetime-entry'] = turn_around_time.apply(lambda row: substract_seconds(row['datetime-leave'], row['seconds']), axis=1, result_type='reduce')
    turn_around_time['datetime-entry']  = turn_around_time['datetime-entry'].dt.round('1s')
    turn_around_time['date-entry'] = turn_around_time['datetime-entry'].dt.date
    turn_around_time['date-entry'] = turn_around_time['date-entry'].astype(str)


    ### get the final port calls
    port_calls = pd.merge(turn_around_time, merged_time_series_first_select_2, on=['date-entry','mmsi'])
    port_calls['draught-diff'] = port_calls['draught-out'] - port_calls['draught-in']
    port_calls['heading-diff'] = port_calls['heading-out'] - port_calls['heading-in']

    ### check if vessels are passing by
    port_calls['passing'] = port_calls.apply(passing_by, axis = 1)
    port_calls = port_calls[port_calls['passing']!= 1]

    ### add information
    port_calls['port-name'] = str(port)
    port_calls['country'] = str(country)

    return port_calls
