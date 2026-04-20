#!/usr/bin/env python3
import urllib.request
import xml.etree.ElementTree as ET
import sys
import re
import os

# Location where to store the playlist files
PLAYLIST_DIR = os.path.expanduser("~/.config/mpd/playlists")

def load_feeds_from_file(path):
     """Loads podcast RSS feed URLs from a text file (one URL per line, # for comments)."""                    
     feeds = []                                                                                                
     with open(path, encoding='utf-8') as f:                                                                   
         for line in f:                                                                                        
             line = line.strip()
             if line and not line.startswith('#'):                                                             
                 feeds.append(line)
     return feeds
 
def slugify(text):
    """Converts a string to a safe filename by replacing non-alphanumeric characters with underscores."""
    return re.sub(r'\W+', '_', text).strip('_')

def parse_duration(d):
    parts = d.split(':')
    try:
        if len(parts) == 3:
            return int(parts[0])*3600 + int(parts[1])*60 + int(parts[2])
        elif len(parts) == 2:
            return int(parts[0])*60 + int(parts[1])
        return int(d)
    except ValueError:
        return -1

def fetch_and_create_m3u(rss_url):
    """Fetches the RSS feed, extracts episode information, and creates an M3U playlist."""
    itunes_ns = 'http://www.itunes.com/dtds/podcast-1.0.dtd'
    try:
        # Set header with User-Agent to avoid potential blocking by some servers
        headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'}
        req = urllib.request.Request(rss_url, headers=headers)

        with urllib.request.urlopen(req) as response:
            xml_data = response.read()
            root = ET.fromstring(xml_data)

            # Podcast-Titel for the playlist filename and EXTINF entries
            channel_title = root.findtext(".//channel/title") or "Unknown_Podcast"
            safe_title = slugify(channel_title)
            file_path = os.path.join(PLAYLIST_DIR, f"podcast_{safe_title}.m3u")

            with open(file_path, 'w', encoding='utf-8') as f:
                f.write("#EXTM3U\n")

                # Iterate all episodes in the RSS feed
                # TODO: limit to the latest 20 episodes if there are too many
                for item in root.findall(".//item"):
                    episode_title = item.findtext("title") or "Unknown Episode"
                    enclosure = item.find("enclosure")

                    if enclosure is not None and enclosure.get('url'):
                        audio_url = enclosure.get('url')
                        duration_text = item.findtext(f'{{{itunes_ns}}}duration') or '-1'
                        secs = parse_duration(duration_text)
                        f.write(f'#EXTINF:{secs},{channel_title} - {episode_title}\n')
                        f.write(f"{audio_url}\n")

            print(f"Successfully updated: {file_path}")

    except Exception as e:
        print(f"Error on {rss_url}: {e}", file=sys.stderr)

def main():
    # Ensure the playlist directory exists
    if not os.path.exists(PLAYLIST_DIR):
        os.makedirs(PLAYLIST_DIR)
        print(f"Directory created: {PLAYLIST_DIR}")

    feeds_file = os.path.expanduser("~/podcasts.txt")                                                     
    feeds = load_feeds_from_file(feeds_file)                                                                      
    for feed in feeds:
        fetch_and_create_m3u(feed)                                                                                
   
if __name__ == "__main__":
    main()
