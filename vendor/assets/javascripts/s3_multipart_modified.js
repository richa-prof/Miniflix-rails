(function(global) {
  global.S3MP = (function() {

    // Wrap this into underscore library extension
    _.mixin({
      findIndex : function (collection, filter) {
        for (var i = 0; i < collection.length; i++) {
          if (filter(collection[i], i, collection)) {
            return i;
          }
        }
        return -1;
      }
    });
// S3MP Constructor
function S3MP(options) {
  var files
    , progress_timer = []
    , S3MP = this;

  _.extend(this, options);
  this.headers = _.object(_.map(options.headers, function(v,k) { return ["x-amz-" + k.toLowerCase(), v] }));

  this.uploadList = [];

  // Handles all of the success/failure events, and
  // progress notifiers
  this.handler = {

    // Activate an appropriate number of parts (number = pipes)
    // when all of the parts have been successfully initialized
    beginUpload: function() {
      var i = [];
      function beginUpload(pipes, uploadObj) {
        var key = uploadObj.key
          , num_parts = uploadObj.parts.length;

        if (typeof i[key] === "undefined") {
          i[key] = 0;
        }

        i[key]++;

        if (i[key] === num_parts) {
          for (var j=0; j<pipes; j++) {
            uploadObj.parts[j].activate();
          }
          S3MP.handler.startProgressTimer(key);
          S3MP.onStart(uploadObj); // This probably needs to go somewhere else.
        }
      }
      return beginUpload;
    }(),

    // called when an upload is paused or the network connection cuts out
    onError: function(uploadObj, part) {
      part.status = "cancel";
      S3MP.onError(uploadObj, part);
    },

    // called when a single part has successfully uploaded
    onPartSuccess: function(uploadObj, finished_part) {
      var parts, i, ETag;

      parts = uploadObj.parts;
      finished_part.status = "complete";

      // Append the ETag (in the response header) to the ETags array
      ETag = finished_part.xhr.getResponseHeader("ETag");
      uploadObj.Etags.push({ ETag: ETag.replace(/\"/g, ''), partNum: finished_part.num });

      // Increase the uploaded count and delete the finished part
      uploadObj.uploaded += finished_part.size;
      uploadObj.inprogress[finished_part.num] = 0;
      i = _.indexOf(parts, finished_part);
      parts.splice(i,1);

      // activate one of the remaining parts
      if (parts.length) {
        i = _.findIndex(parts, function(el, index, collection) {
          if (el.status !== "active") {
            return true;
          }
        });
        if (i !== -1){
          parts[i].activate();
        }
      }

      // If no parts remain then the upload has finished
      if (!parts.length) {
        this.onComplete(uploadObj);
      }
    },

    // called when all parts have successfully uploaded
    onComplete: function(uploadObj) {
      var key = _.indexOf(S3MP.uploadList, uploadObj);

      // Stop the onprogress timer
      this.clearProgressTimer(key);

      // Tell the server to put together the pieces
      S3MP.completeMultipart(uploadObj, function(obj) {
        // Notify the client that the upload has succeeded when we
        // get confirmation from the server
        if (obj.location) {
          S3MP.onComplete(uploadObj);
        }
      });

    },

    // Called by progress_timer
    onProgress: function(key, size, done, percent, speed) {
      S3MP.onProgress(key, size, done, percent, speed);
    },

    startProgressTimer: function() {
      var last_upload_chunk = [];
      var fn = function(key) {
        progress_timer[key] = global.setInterval(function() {
          var upload, size, done, percent, speed;

          if (typeof last_upload_chunk[key] === "undefined") {
            last_upload_chunk[key] = 0;
          }

          upload = S3MP.uploadList[key];
          size = upload.size;
          done = upload.uploaded;

          _.each(upload.inprogress,function(val, index) {
            part_available = _.find(upload.parts, function(part){
              return part.num == index
            })

            if(part_available)
              done += val;
          });

          percent = done/size * 100;
          speed = done - last_upload_chunk[key];
          last_upload_chunk[key] = done;

          upload.handler.onProgress(key, size, done, percent, speed);
        }, 1000);
      };
      return fn;
    }(),

    clearProgressTimer: function(key) {
      global.clearInterval(progress_timer[key]);
    }

  };

  // List of files may come from a FileList object or an array of files
  if (this.fileSelector) {
    files = $(this.fileSelector).get(0).files; // FileList object
  } else {
    files = this.fileList; // array specified in configuration
  }

  _.each(files, function(file, key) {
    if (file.size < 5000000) {
      return S3MP.onError({name: "FileSizeError", message: "File size is too small"})
      // This should still work. The multipart API just can't be used b/c Amazon doesn't allow
      // multipart file uploads that are less than 5 mb in size.
    }

    var upload = new Upload(file, S3MP, key);
    S3MP.uploadList.push(upload);
    upload.init();
  });

};

S3MP.prototype.initiateMultipart = function(upload, cb) {
  var url, body, xhr;

  url = '/s3_multipart/uploads';
  body = JSON.stringify({ object_name  : upload.name,
                          content_type : upload.type,
                          content_size : upload.size,
                          headers      : this.headers,
                          uploader     : $(this.fileInputElement).data("uploader")
                        });

  xhr = this.createXhrRequest('POST', url);
  this.deliverRequest(xhr, body, cb);

};

S3MP.prototype.signPartRequests = function(id, object_name, upload_id, parts, cb) {
  var content_lengths, url, body, xhr;

  content_lengths = _.reduce(_.rest(parts), function(memo, part) {
    return memo + "-" + part.size;
  }, parts[0].size);

  part_numbers = _.reduce(_.rest(parts), function(memo, part) {
    return memo + "-" + part.num;
  }, parts[0].num);

  url = "/s3_multipart/uploads/"+id;
  body = JSON.stringify({ object_name     : object_name,
                          upload_id       : upload_id,
                          content_lengths : content_lengths,
                          part_numbers     : part_numbers
                        });

  xhr = this.createXhrRequest('PUT', url);
  this.deliverRequest(xhr, body, cb, parts);
};

S3MP.prototype.completeMultipart = function(uploadObj, cb) {
  var url, body, xhr;

  url = '/s3_multipart/uploads/'+uploadObj.id;
  body = JSON.stringify({ object_name    : uploadObj.object_name,
                          upload_id      : uploadObj.upload_id,
                          content_length : uploadObj.size,
                          parts          : uploadObj.Etags
                        });

  xhr = this.createXhrRequest('PUT', url);
  this.deliverRequest(xhr, body, cb);
};

// Specify callbacks, request body, and settings for requests that contact
// the site server, and send the request.
S3MP.prototype.deliverRequest = function(xhr, body, cb, part) {
  var self = this;

  xhr.onload = function() {
    response = JSON.parse(this.responseText);
    if (response.error) {
      return self.onError({
        name: "ServerResponse",
        message: response.error
      });
    }
    cb(response, part);
  };

  xhr.onerror = function() {
    console.log("onerror invoke for xhr request under part " + part[0].num + " re activating it.");
    part[0].activate();
  };

  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));

  xhr.send(body);
}

S3MP.prototype.createXhrRequest = function() {
  var xhrRequest;

  // Sniff for xhr object
  if (typeof XMLHttpRequest.constructor === "function") {
    xhrRequest = XMLHttpRequest;
  } else if (typeof XDomainRequest !== "undefined") {
    xhrRequest = XDomainRequest;
  } else {
    xhrRequest = null; // Error out to the client (To-do)
  }

  return function(method, url, cb, open) { // open defaults to true
    var args, xhr, open = true;

    args = Array.prototype.slice.call(arguments);
    if (typeof args[0] === "undefined") {
      cb = null;
      open = false;
    }

    xhr = new xhrRequest();
    if (open) { // open the request unless specified otherwise
      xhr.open(method, url, true);
    }
    xhr.onreadystatechange = cb;

    return xhr;
  };

}();

S3MP.prototype.sliceBlob = function() {
  try {
    var test_blob = new Blob();
  } catch(e) {
    return "Unsupported";
  }

  if (test_blob.slice) {
    return function(blob, start, end) {
      return blob.slice(start, end);
    }
  } else if (test_blob.mozSlice) {
    return function(blob, start, end) {
      return blob.mozSlice(start, end);
    }
  } else if (test_blob.webkitSlice) {
    return function(blob, start, end) {
      return blob.webkitSlice(start, end);
    }
  } else {
    return "Unsupported";
  }
}();

// utility function to return an upload object given a file
S3MP.prototype._returnUploadObj = function(key) {
  var uploadObj = _.find(this.uploadList, function(uploadObj) {
    return uploadObj.key === key;
  });
  return uploadObj;
};

// cancel a given file upload
S3MP.prototype.cancel = function(key) {
  var uploadObj, i;

  uploadObj = this._returnUploadObj(key);
  i = _.indexOf(this.uploadList, uploadObj);

  this.uploadList.splice(i,i+1);
  this.onCancel();
};

// pause a given file upload
S3MP.prototype.pause = function(key) {
  var uploadObj = this._returnUploadObj(key);

  _.each(uploadObj.parts, function(part, key, list) {
    if (part.status == "active") {
      part.pause();
    }
  });

  this.onPause();
};

// resume a given file upload
S3MP.prototype.resume = function(key) {
  var uploadObj = this._returnUploadObj(key);

  _.each(uploadObj.parts, function(part, key, list) {
    if (part.status == "paused") {
      part.activate();
    }
  });

  this.onResume();
};

// Upload constructor
function Upload(file, o, key) {
  function Upload() {
    var upload, id, parts, part, segs, chunk_segs, chunk_lens, pipes, blob;

    upload = this;

    this.key = key;
    this.file = file;
    this.name = file.name;
    this.size = file.size;
    this.type = file.type;
    this.Etags = [];
    this.inprogress = [];
    this.uploaded = 0;
    this.status = "";

    // Break the file into an appropriate amount of chunks
    // This needs to be optimized for various browsers types/versions
    // Minimum size for aws s3 is 5242880
    if (this.size > 1050000000) { // size greater than 1gb
      num_segs = 200;
      pipes = 5;
    }
    else if (this.size > 1000000000) { // size greater than 1gb
      num_segs = 190;
      pipes = 5;
    } else if (this.size > 500000000) { // greater than 500mb
      num_segs = 50;
      pipes = 5;
    } else if (this.size > 100000000) { // greater than 100 mb
      num_segs = 18;
      pipes = 5;
    } else if (this.size > 50000000) { // greater than 50 mb
      num_segs = 5;
      pipes = 2;
    } else if (this.size > 10500000) { // greater than 10 mb
      num_segs = 2;
      pipes = 2;
    } else { // greater than 5 mb (S3 does not allow multipart uploads < 5 mb)
      num_segs = 1;
      pipes = 1;
    }

    chunk_segs = _.range(num_segs + 1);
    chunk_lens = _.map(chunk_segs, function(seg) {
      return Math.round(seg * (file.size/num_segs));
    });

    if (upload.sliceBlob == "Unsupported") {
      this.parts = [new UploadPart(file, 0, upload)];
    } else {
      this.parts = _.map(chunk_lens, function(len, i) {
        blob = upload.sliceBlob(file, len, chunk_lens[i+1]);
        return new UploadPart(blob, i+1, upload);
      });
      this.parts.pop(); // Remove the empty blob at the end of the array
    }

    // init function will initiate the multipart upload, sign all the parts, and
    // start uploading some parts in parallel
    this.init = function() {
      upload.initiateMultipart(upload, function(obj) {
        var id = upload.id = obj.id
          , upload_id = upload.upload_id = obj.upload_id
          , object_name = upload.object_name = obj.key // uuid generated by the server, different from name
          , parts = upload.parts;

        upload.signPartRequests(id, object_name, upload_id, parts, function(response) {
          _.each(parts, function(part, key) {
            part.date = response[key].date;
            part.auth = response[key].authorization;
            // Notify handler that an xhr request has been opened
            upload.handler.beginUpload(pipes, upload);
          });
        });
      });
    }
  };
  // Inherit the properties and prototype methods of the passed in S3MP instance object
  Upload.prototype = o;
  return new Upload();
}

// Upload part constructor
function UploadPart(blob, key, upload) {
  var part, xhr;

  part = this;

  this.size = blob.size;
  this.blob = blob;
  this.num = key;
  this.upload = upload;

  this.xhr = xhr = upload.createXhrRequest();
  xhr.onload = function() {
    upload.handler.onPartSuccess(upload, part);
  };
  xhr.onerror = function() {
    upload.handler.onError(upload, part);
  };
  xhr.upload.onprogress = _.throttle(function(e) {
    if (e.lengthComputable) {
      upload.inprogress[key] = e.loaded;
    }
  }, 1000);

};

UploadPart.prototype.activate = function() {

  current_time = new Date();
  part_date = new Date(this.date);

  if( (current_time - part_date)/1000/60 > 15 ){ //x-amz-date is greater then 15 Min so get a new date and auth token
    console.log("Getting new signed path from server as x-amz-date expired for part number " + this.num);
    this.upload.signPartRequests(this.upload.id, this.upload.object_name, this.upload.upload_id, [this], function(response, part) {

      console.log("Got new signed path from server , going to start the chunk upload for part number " +  part[0].num);
      part = part[0];
      part.date = response[0].date;
      part.auth = response[0].authorization;
      part.activate();

    });
  }else{

    this.xhr.open('PUT', '//'+this.upload.bucket+'.s3.amazonaws.com/'+this.upload.object_name+'?partNumber='+this.num+'&uploadId='+this.upload.upload_id, true);
    this.xhr.setRequestHeader('x-amz-date', this.date);
    this.xhr.setRequestHeader('Authorization', this.auth);

    this.xhr.send(this.blob);
    this.status = "active";

  }

};

UploadPart.prototype.pause = function() {
  this.xhr.abort();
  this.status = "paused";
};

return S3MP;

  }());

}(this));
