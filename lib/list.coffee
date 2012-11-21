request = require 'request'

# coffee -e 'require("./lib/list.coffee").getrecentforvenue {foursquareid: "4e1cd66e18a8e423cd4fd37c"}, (cb) -> console.log cb'
listlib = {
	getrecentforvenue: (info, cb) ->
		one_day_ago = (Math.round(Date.now() / 1000) - 86400)
		if process.env.IGKEY != undefined
			if info.foursquareid != undefined
				url = "https://api.instagram.com/v1/locations/search?foursquare_v2_id=" + info.foursquareid + "&client_id=" + process.env.IGKEY
				request {uri: url, timeout: 5000, method: 'GET'}, (error, response, body) ->
					if not error
						try
							json_resp = JSON.parse(body)
						catch e
							json_resp = {meta: {code: 500}}

						if json_resp['meta']['code'] == 200
							# we got location
							location_id = json_resp.data[0].id
							json_resp = {}
							url = "https://api.instagram.com/v1/locations/" + location_id + "/media/recent?min_timestamp=" + one_day_ago.toString() + "&client_id=" + process.env.IGKEY
							request {uri: url, timeout: 5000, method: 'GET'}, (error, response, body) ->
								try
									json_resp = JSON.parse(body)
								catch e
									json_resp = {meta: {code: 500}}

								if json_resp['meta']['code'] == 200
									list_of_media = json_resp.data
									media_processed = []
									for media in list_of_media
										media_processed.push {created: media.created_time, user: media.user, likes: media.likes.count, comments: media.comments.count, hardlink: media.link, images: {thumbnail: media.images.thumbnail, normal: media.images.standard_resolution, crap: media.images.low_resolution}}
									cb({media: media_processed, count: list_of_media.length})
								else
									cb({status: false, message: 'Error returned from instagram', info: body})
						else
							cb({status: false, message: 'Error returned from instagram', info: body})
					else
						cb({status: false, message: 'Error returned from instagram', info: body})
			else
				cb({status: false, message: "no foursquareid set"})
		else
			cb({status: false, message: "no IGKEY environment variable set"})
}
module.exports = listlib
