post "/import" do
  uris = filter_uris_from_inserts(JSON.parse request.body.read)

  turtle_files = filter_turtle_files(uris)

  turtle_files.each do |f|
    load_turtle_file_in_application_graph(f)
  end

  "OK"
end

def filter_uris_from_inserts(jsonbody)
  uris= []
  
  jsonbody["delta"].each do |delta|
    delta["inserts"].each do |triple|
      uris.push(triple["s"]["value"])
    end
  end

  uris.to_set
end
  

def filter_turtle_files(uris)
  turtle_files = []

  files = query(generate_filename_query(uris))

  files.each_solution do |solution|
    turtle_files.push(solution["filename"].to_s)
  end
  
  turtle_files
end

def generate_filename_query(uris)
  query = "SELECT DISTINCT ?filename " + 
          "WHERE " +
          "{ " +
          "?uri a <http://mu.semte.ch/vocabularies/file-service/File> . " +
          "?uri <http://mu.semte.ch/vocabularies/file-service/originalFilename> ?original_filename . " +
          "?uri <http://mu.semte.ch/vocabularies/file-service/filename> ?filename . " +
          "FILTER(strends(?original_filename, \".ttl\")) " +
          "FILTER(?uri in ("

  uris.each do |uri|
    query += "<" + uri + ">,"
  end

  query = query[0..-2]

  query += ")) }"
end

def load_turtle_file_in_application_graph(filename)
  reader = RDF::Turtle::Reader.open(filename)

  query = "WITH <" + ENV['MU_APPLICATION_GRAPH'] + "> INSERT DATA {\n"
  
  reader.each_triple do |subject , predicate , object|
    query += "<" + subject.to_s + "> <" + predicate.to_s + "> "
    if object.literal?
      query += "\"" + object.to_s  + "\" .\n"
    end
    if object.uri?
      query += "<" + object.to_s + "> \n."
    end
  end

  query += "}"
  query(query)
end
