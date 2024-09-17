/* Takes a csv row and turns it into a tuple
 * @params record A map with the fields id, read1, and read2
 * @return List containing a meta map and list of files
 */
def csvRecordToInputTuple(Map record){
    [ 
        [ id: record.id ], 
        [ 
            file( record.read1, checkIfExists: true ), 
            file( record.read2, checkIfExists: true ) 
        ] 
    ]
}

/* Takes a map and makes a yaml file
 * @params mymap A simple Map containing key value pairs
 * @params filename The name of the file to save to
 * @return A channel containing a YAML file with the key values pairs
 */
def mapToYamlFile( Map mymap, String filename ){
    Channel.value( mymap.collect{ key, value -> "$key: $value" }.join('\n') ).collectFile( name: filename )
}