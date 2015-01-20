#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2014 Andrejs Mivreniks <gim@fastmail.fm>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from pathlib import Path
import datetime

import twitter
import dateutil.parser

APP_NAME = "TwitterHomeFeed"
CONSUMER_KEY = "" # You need to get your own key from https://apps.twitter.com/
CONSUMER_SECRET = "" # You need to get your own secret from https://apps.twitter.com/

credentials_file = Path("twitter_oauth_token.txt")
if not credentials_file.exists():
    oauth_token, oauth_secret = twitter.oauth_dance(APP_NAME, CONSUMER_KEY, CONSUMER_SECRET, str(credentials_file))
else:
    oauth_token, oauth_secret = twitter.read_token_file(str(credentials_file))

oauth = twitter.OAuth(oauth_token, oauth_secret, CONSUMER_KEY, CONSUMER_SECRET)
twitter_handler = twitter.Twitter(auth=oauth)

date = datetime.date.today()
until_date = date - datetime.timedelta(1)
last_id = None
while (date > until_date):
    if last_id is not None:
        time_line = twitter_handler.statuses.home_timeline(exclude_replies=True, max_id=last_id)
    else:
        time_line = twitter_handler.statuses.home_timeline(exclude_replies=True)

    date = dateutil.parser.parse(time_line[-1]['created_at']).date()
    last_id = time_line[-1]['id']

    for twit in time_line:
        print(twit['user']['name'], "(@" + twit['user']['screen_name'] + ")", twit['created_at'])
        print(twit['text'])
        print('--------------------')
