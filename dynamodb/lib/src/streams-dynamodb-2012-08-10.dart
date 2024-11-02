// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name

import 'dart:convert';
import 'dart:typed_data';
import 'package:dynamodb/src/aws_client.dart';

import 'attribute_value.dart';
import 'package:shared_aws_api/shared.dart' as _s;
import 'package:shared_aws_api/shared.dart'
    show
        rfc822ToJson,
        iso8601ToJson,
        unixTimestampToJson,
        nonNullableTimeStampFromJson,
        timeStampFromJson;

export 'package:shared_aws_api/shared.dart' show AwsClientCredentials;


/// Amazon DynamoDB Streams provides API actions for accessing streams and
/// processing stream records. To learn more about application development with
/// Streams, see <a
/// href="https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html">Capturing
/// Table Activity with DynamoDB Streams</a> in the Amazon DynamoDB Developer
/// Guide.
class DynamoDBStreams extends AwsClient {
  DynamoDBStreams({
    required super.region,
    super.credentials,
    super.credentialsProvider,
    super.client,
    super.endpointUrl,
  }) : super(
            service: _s.ServiceMetadata(
                endpointPrefix: 'streams.dynamodb', signingName: 'dynamodb'));

  /// Returns information about a stream, including the current status of the
  /// stream, its Amazon Resource Name (ARN), the composition of its shards, and
  /// its corresponding DynamoDB table.
  /// <note>
  /// You can call <code>DescribeStream</code> at a maximum rate of 10 times per
  /// second.
  /// </note>
  /// Each shard in the stream has a <code>SequenceNumberRange</code> associated
  /// with it. If the <code>SequenceNumberRange</code> has a
  /// <code>StartingSequenceNumber</code> but no
  /// <code>EndingSequenceNumber</code>, then the shard is still open (able to
  /// receive more stream records). If both <code>StartingSequenceNumber</code>
  /// and <code>EndingSequenceNumber</code> are present, then that shard is
  /// closed and can no longer receive more data.
  ///
  /// May throw [ResourceNotFoundException].
  /// May throw [InternalServerError].
  ///
  /// Parameter [streamArn] :
  /// The Amazon Resource Name (ARN) for the stream.
  ///
  /// Parameter [exclusiveStartShardId] :
  /// The shard ID of the first item that this operation will evaluate. Use the
  /// value that was returned for <code>LastEvaluatedShardId</code> in the
  /// previous operation.
  ///
  /// Parameter [limit] :
  /// The maximum number of shard objects to return. The upper limit is 100.
  Future<DescribeStreamOutput> describeStream({
    required String streamArn,
    String? exclusiveStartShardId,
    int? limit,
  }) async {
    _s.validateNumRange('limit', limit, 1, 1152921504606846976);
    final headers = <String, String>{
      'Content-Type': 'application/x-amz-json-1.0',
      'X-Amz-Target': 'DynamoDBStreams_20120810.DescribeStream'
    };
    final jsonResponse = await protocol.send(
      method: 'POST',
      requestUri: '/',
      exceptionFnMap: _exceptionFns,
      // TODO queryParams
      headers: headers,
      payload: {
        'StreamArn': streamArn,
        if (exclusiveStartShardId != null)
          'ExclusiveStartShardId': exclusiveStartShardId,
        if (limit != null) 'Limit': limit,
      },
    );

    return DescribeStreamOutput.fromJson(jsonResponse.body);
  }

  /// Retrieves the stream records from a given shard.
  ///
  /// Specify a shard iterator using the <code>ShardIterator</code> parameter.
  /// The shard iterator specifies the position in the shard from which you want
  /// to start reading stream records sequentially. If there are no stream
  /// records available in the portion of the shard that the iterator points to,
  /// <code>GetRecords</code> returns an empty list. Note that it might take
  /// multiple calls to get to a portion of the shard that contains stream
  /// records.
  /// <note>
  /// <code>GetRecords</code> can retrieve a maximum of 1 MB of data or 1000
  /// stream records, whichever comes first.
  /// </note>
  ///
  /// May throw [ResourceNotFoundException].
  /// May throw [LimitExceededException].
  /// May throw [InternalServerError].
  /// May throw [ExpiredIteratorException].
  /// May throw [TrimmedDataAccessException].
  ///
  /// Parameter [shardIterator] :
  /// A shard iterator that was retrieved from a previous GetShardIterator
  /// operation. This iterator can be used to access the stream records in this
  /// shard.
  ///
  /// Parameter [limit] :
  /// The maximum number of records to return from the shard. The upper limit is
  /// 1000.
  Future<GetRecordsOutput> getRecords({
    required String shardIterator,
    int? limit,
  }) async {
    _s.validateNumRange(
      'limit',
      limit,
      1,
      1152921504606846976,
    );
    final headers = <String, String>{
      'Content-Type': 'application/x-amz-json-1.0',
      'X-Amz-Target': 'DynamoDBStreams_20120810.GetRecords'
    };
    final jsonResponse = await protocol.send(
      method: 'POST',
      requestUri: '/',
      exceptionFnMap: _exceptionFns,
      // TODO queryParams
      headers: headers,
      payload: {
        'ShardIterator': shardIterator,
        if (limit != null) 'Limit': limit,
      },
    );

    return GetRecordsOutput.fromJson(jsonResponse.body);
  }

  /// Returns a shard iterator. A shard iterator provides information about how
  /// to retrieve the stream records from within a shard. Use the shard iterator
  /// in a subsequent <code>GetRecords</code> request to read the stream records
  /// from the shard.
  /// <note>
  /// A shard iterator expires 15 minutes after it is returned to the requester.
  /// </note>
  ///
  /// May throw [ResourceNotFoundException].
  /// May throw [InternalServerError].
  /// May throw [TrimmedDataAccessException].
  ///
  /// Parameter [shardId] :
  /// The identifier of the shard. The iterator will be returned for this shard
  /// ID.
  ///
  /// Parameter [shardIteratorType] :
  /// Determines how the shard iterator is used to start reading stream records
  /// from the shard:
  ///
  /// <ul>
  /// <li>
  /// <code>AT_SEQUENCE_NUMBER</code> - Start reading exactly from the position
  /// denoted by a specific sequence number.
  /// </li>
  /// <li>
  /// <code>AFTER_SEQUENCE_NUMBER</code> - Start reading right after the
  /// position denoted by a specific sequence number.
  /// </li>
  /// <li>
  /// <code>TRIM_HORIZON</code> - Start reading at the last (untrimmed) stream
  /// record, which is the oldest record in the shard. In DynamoDB Streams,
  /// there is a 24 hour limit on data retention. Stream records whose age
  /// exceeds this limit are subject to removal (trimming) from the stream.
  /// </li>
  /// <li>
  /// <code>LATEST</code> - Start reading just after the most recent stream
  /// record in the shard, so that you always read the most recent data in the
  /// shard.
  /// </li>
  /// </ul>
  ///
  /// Parameter [streamArn] :
  /// The Amazon Resource Name (ARN) for the stream.
  ///
  /// Parameter [sequenceNumber] :
  /// The sequence number of a stream record in the shard from which to start
  /// reading.
  Future<GetShardIteratorOutput> getShardIterator({
    required String shardId,
    required ShardIteratorType shardIteratorType,
    required String streamArn,
    String? sequenceNumber,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/x-amz-json-1.0',
      'X-Amz-Target': 'DynamoDBStreams_20120810.GetShardIterator'
    };
    final jsonResponse = await protocol.send(
      method: 'POST',
      requestUri: '/',
      exceptionFnMap: _exceptionFns,
      // TODO queryParams
      headers: headers,
      payload: {
        'ShardId': shardId,
        'ShardIteratorType': shardIteratorType.value,
        'StreamArn': streamArn,
        if (sequenceNumber != null) 'SequenceNumber': sequenceNumber,
      },
    );

    return GetShardIteratorOutput.fromJson(jsonResponse.body);
  }

  /// Returns an array of stream ARNs associated with the current account and
  /// endpoint. If the <code>TableName</code> parameter is present, then
  /// <code>ListStreams</code> will return only the streams ARNs for that table.
  /// <note>
  /// You can call <code>ListStreams</code> at a maximum rate of 5 times per
  /// second.
  /// </note>
  ///
  /// May throw [ResourceNotFoundException].
  /// May throw [InternalServerError].
  ///
  /// Parameter [exclusiveStartStreamArn] :
  /// The ARN (Amazon Resource Name) of the first item that this operation will
  /// evaluate. Use the value that was returned for
  /// <code>LastEvaluatedStreamArn</code> in the previous operation.
  ///
  /// Parameter [limit] :
  /// The maximum number of streams to return. The upper limit is 100.
  ///
  /// Parameter [tableName] :
  /// If this parameter is provided, then only the streams associated with this
  /// table name are returned.
  Future<ListStreamsOutput> listStreams({
    String? exclusiveStartStreamArn,
    int? limit,
    String? tableName,
  }) async {
    _s.validateNumRange(
      'limit',
      limit,
      1,
      1152921504606846976,
    );
    final headers = <String, String>{
      'Content-Type': 'application/x-amz-json-1.0',
      'X-Amz-Target': 'DynamoDBStreams_20120810.ListStreams'
    };
    final jsonResponse = await protocol.send(
      method: 'POST',
      requestUri: '/',
      exceptionFnMap: _exceptionFns,
      // TODO queryParams
      headers: headers,
      payload: {
        if (exclusiveStartStreamArn != null)
          'ExclusiveStartStreamArn': exclusiveStartStreamArn,
        if (limit != null) 'Limit': limit,
        if (tableName != null) 'TableName': tableName,
      },
    );

    return ListStreamsOutput.fromJson(jsonResponse.body);
  }
}

/// Represents the output of a <code>DescribeStream</code> operation.
class DescribeStreamOutput {
  /// A complete description of the stream, including its creation date and time,
  /// the DynamoDB table associated with the stream, the shard IDs within the
  /// stream, and the beginning and ending sequence numbers of stream records
  /// within the shards.
  final StreamDescription? streamDescription;

  DescribeStreamOutput({
    this.streamDescription,
  });

  factory DescribeStreamOutput.fromJson(Map<String, dynamic> json) {
    return DescribeStreamOutput(
      streamDescription: json['StreamDescription'] != null
          ? StreamDescription.fromJson(
              json['StreamDescription'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Represents the output of a <code>GetRecords</code> operation.
class GetRecordsOutput {
  /// The next position in the shard from which to start sequentially reading
  /// stream records. If set to <code>null</code>, the shard has been closed and
  /// the requested iterator will not return any more data.
  final String? nextShardIterator;

  /// The stream records from the shard, which were retrieved using the shard
  /// iterator.
  final List<Record>? records;

  GetRecordsOutput({
    this.nextShardIterator,
    this.records,
  });

  factory GetRecordsOutput.fromJson(Map<String, dynamic> json) {
    return GetRecordsOutput(
      nextShardIterator: json['NextShardIterator'] as String?,
      records: (json['Records'] as List?)
          ?.nonNulls
          .map((e) => Record.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents the output of a <code>GetShardIterator</code> operation.
class GetShardIteratorOutput {
  /// The position in the shard from which to start reading stream records
  /// sequentially. A shard iterator specifies this position using the sequence
  /// number of a stream record in a shard.
  final String? shardIterator;

  GetShardIteratorOutput({
    this.shardIterator,
  });

  factory GetShardIteratorOutput.fromJson(Map<String, dynamic> json) {
    return GetShardIteratorOutput(
      shardIterator: json['ShardIterator'] as String?,
    );
  }
}

/// Contains details about the type of identity that made the request.
class Identity {
  /// A unique identifier for the entity that made the call. For Time To Live, the
  /// principalId is "dynamodb.amazonaws.com".
  final String? principalId;

  /// The type of the identity. For Time To Live, the type is "Service".
  final String? type;

  Identity({
    this.principalId,
    this.type,
  });

  factory Identity.fromJson(Map<String, dynamic> json) {
    return Identity(
      principalId: json['PrincipalId'] as String?,
      type: json['Type'] as String?,
    );
  }
}

/// Represents <i>a single element</i> of a key schema. A key schema specifies
/// the attributes that make up the primary key of a table, or the key
/// attributes of an index.
///
/// A <code>KeySchemaElement</code> represents exactly one attribute of the
/// primary key. For example, a simple primary key would be represented by one
/// <code>KeySchemaElement</code> (for the partition key). A composite primary
/// key would require one <code>KeySchemaElement</code> for the partition key,
/// and another <code>KeySchemaElement</code> for the sort key.
///
/// A <code>KeySchemaElement</code> must be a scalar, top-level attribute (not a
/// nested attribute). The data type must be one of String, Number, or Binary.
/// The attribute cannot be nested within a List or a Map.
class KeySchemaElement {
  /// The name of a key attribute.
  final String attributeName;

  /// The role that this key attribute will assume:
  ///
  /// <ul>
  /// <li>
  /// <code>HASH</code> - partition key
  /// </li>
  /// <li>
  /// <code>RANGE</code> - sort key
  /// </li>
  /// </ul> <note>
  /// The partition key of an item is also known as its <i>hash attribute</i>. The
  /// term "hash attribute" derives from DynamoDB's usage of an internal hash
  /// function to evenly distribute data items across partitions, based on their
  /// partition key values.
  ///
  /// The sort key of an item is also known as its <i>range attribute</i>. The
  /// term "range attribute" derives from the way DynamoDB stores items with the
  /// same partition key physically close together, in sorted order by the sort
  /// key value.
  /// </note>
  final KeyType keyType;

  KeySchemaElement({
    required this.attributeName,
    required this.keyType,
  });

  factory KeySchemaElement.fromJson(Map<String, dynamic> json) {
    return KeySchemaElement(
      attributeName: json['AttributeName'] as String,
      keyType: KeyType.fromString((json['KeyType'] as String)),
    );
  }
}

enum KeyType {
  hash('HASH'),
  range('RANGE'),
  ;

  final String value;

  const KeyType(this.value);

  static KeyType fromString(String value) =>
      values.firstWhere((e) => e.value == value,
          orElse: () => throw Exception('$value is not known in enum KeyType'));
}

/// Represents the output of a <code>ListStreams</code> operation.
class ListStreamsOutput {
  /// The stream ARN of the item where the operation stopped, inclusive of the
  /// previous result set. Use this value to start a new operation, excluding this
  /// value in the new request.
  ///
  /// If <code>LastEvaluatedStreamArn</code> is empty, then the "last page" of
  /// results has been processed and there is no more data to be retrieved.
  ///
  /// If <code>LastEvaluatedStreamArn</code> is not empty, it does not necessarily
  /// mean that there is more data in the result set. The only way to know when
  /// you have reached the end of the result set is when
  /// <code>LastEvaluatedStreamArn</code> is empty.
  final String? lastEvaluatedStreamArn;

  /// A list of stream descriptors associated with the current account and
  /// endpoint.
  final List<Stream>? streams;

  ListStreamsOutput({
    this.lastEvaluatedStreamArn,
    this.streams,
  });

  factory ListStreamsOutput.fromJson(Map<String, dynamic> json) {
    return ListStreamsOutput(
      lastEvaluatedStreamArn: json['LastEvaluatedStreamArn'] as String?,
      streams: (json['Streams'] as List?)
          ?.nonNulls
          .map((e) => Stream.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum OperationType {
  insert('INSERT'),
  modify('MODIFY'),
  remove('REMOVE'),
  ;

  final String value;

  const OperationType(this.value);

  static OperationType fromString(String value) =>
      values.firstWhere((e) => e.value == value,
          orElse: () =>
              throw Exception('$value is not known in enum OperationType'));
}

/// A description of a unique event within a stream.
class Record {
  /// The region in which the <code>GetRecords</code> request was received.
  final String? awsRegion;

  /// The main body of the stream record, containing all of the DynamoDB-specific
  /// fields.
  final StreamRecord? dynamodb;

  /// A globally unique identifier for the event that was recorded in this stream
  /// record.
  final String? eventID;

  /// The type of data modification that was performed on the DynamoDB table:
  ///
  /// <ul>
  /// <li>
  /// <code>INSERT</code> - a new item was added to the table.
  /// </li>
  /// <li>
  /// <code>MODIFY</code> - one or more of an existing item's attributes were
  /// modified.
  /// </li>
  /// <li>
  /// <code>REMOVE</code> - the item was deleted from the table
  /// </li>
  /// </ul>
  final OperationType? eventName;

  /// The Amazon Web Services service from which the stream record originated. For
  /// DynamoDB Streams, this is <code>aws:dynamodb</code>.
  final String? eventSource;

  /// The version number of the stream record format. This number is updated
  /// whenever the structure of <code>Record</code> is modified.
  ///
  /// Client applications must not assume that <code>eventVersion</code> will
  /// remain at a particular value, as this number is subject to change at any
  /// time. In general, <code>eventVersion</code> will only increase as the
  /// low-level DynamoDB Streams API evolves.
  final String? eventVersion;

  /// Items that are deleted by the Time to Live process after expiration have the
  /// following fields:
  ///
  /// <ul>
  /// <li>
  /// Records[].userIdentity.type
  ///
  /// "Service"
  /// </li>
  /// <li>
  /// Records[].userIdentity.principalId
  ///
  /// "dynamodb.amazonaws.com"
  /// </li>
  /// </ul>
  final Identity? userIdentity;

  Record({
    this.awsRegion,
    this.dynamodb,
    this.eventID,
    this.eventName,
    this.eventSource,
    this.eventVersion,
    this.userIdentity,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      awsRegion: json['awsRegion'] as String?,
      dynamodb: json['dynamodb'] != null
          ? StreamRecord.fromJson(json['dynamodb'] as Map<String, dynamic>)
          : null,
      eventID: json['eventID'] as String?,
      eventName: (json['eventName'] as String?)?.let(OperationType.fromString),
      eventSource: json['eventSource'] as String?,
      eventVersion: json['eventVersion'] as String?,
      userIdentity: json['userIdentity'] != null
          ? Identity.fromJson(json['userIdentity'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// The beginning and ending sequence numbers for the stream records contained
/// within a shard.
class SequenceNumberRange {
  /// The last sequence number for the stream records contained within a shard.
  /// String contains numeric characters only.
  final String? endingSequenceNumber;

  /// The first sequence number for the stream records contained within a shard.
  /// String contains numeric characters only.
  final String? startingSequenceNumber;

  SequenceNumberRange({
    this.endingSequenceNumber,
    this.startingSequenceNumber,
  });

  factory SequenceNumberRange.fromJson(Map<String, dynamic> json) {
    return SequenceNumberRange(
      endingSequenceNumber: json['EndingSequenceNumber'] as String?,
      startingSequenceNumber: json['StartingSequenceNumber'] as String?,
    );
  }
}

/// A uniquely identified group of stream records within a stream.
class Shard {
  /// The shard ID of the current shard's parent.
  final String? parentShardId;

  /// The range of possible sequence numbers for the shard.
  final SequenceNumberRange? sequenceNumberRange;

  /// The system-generated identifier for this shard.
  final String? shardId;

  Shard({
    this.parentShardId,
    this.sequenceNumberRange,
    this.shardId,
  });

  factory Shard.fromJson(Map<String, dynamic> json) {
    return Shard(
      parentShardId: json['ParentShardId'] as String?,
      sequenceNumberRange: json['SequenceNumberRange'] != null
          ? SequenceNumberRange.fromJson(
              json['SequenceNumberRange'] as Map<String, dynamic>)
          : null,
      shardId: json['ShardId'] as String?,
    );
  }
}

enum ShardIteratorType {
  trimHorizon('TRIM_HORIZON'),
  latest('LATEST'),
  atSequenceNumber('AT_SEQUENCE_NUMBER'),
  afterSequenceNumber('AFTER_SEQUENCE_NUMBER'),
  ;

  final String value;

  const ShardIteratorType(this.value);

  static ShardIteratorType fromString(String value) =>
      values.firstWhere((e) => e.value == value,
          orElse: () =>
              throw Exception('$value is not known in enum ShardIteratorType'));
}

/// Represents all of the data describing a particular stream.
class Stream {
  /// The Amazon Resource Name (ARN) for the stream.
  final String? streamArn;

  /// A timestamp, in ISO 8601 format, for this stream.
  ///
  /// Note that <code>LatestStreamLabel</code> is not a unique identifier for the
  /// stream, because it is possible that a stream from another table might have
  /// the same timestamp. However, the combination of the following three elements
  /// is guaranteed to be unique:
  ///
  /// <ul>
  /// <li>
  /// the Amazon Web Services customer ID.
  /// </li>
  /// <li>
  /// the table name
  /// </li>
  /// <li>
  /// the <code>StreamLabel</code>
  /// </li>
  /// </ul>
  final String? streamLabel;

  /// The DynamoDB table with which the stream is associated.
  final String? tableName;

  Stream({
    this.streamArn,
    this.streamLabel,
    this.tableName,
  });

  factory Stream.fromJson(Map<String, dynamic> json) {
    return Stream(
      streamArn: json['StreamArn'] as String?,
      streamLabel: json['StreamLabel'] as String?,
      tableName: json['TableName'] as String?,
    );
  }
}

/// Represents all of the data describing a particular stream.
class StreamDescription {
  /// The date and time when the request to create this stream was issued.
  final DateTime? creationRequestDateTime;

  /// The key attribute(s) of the stream's DynamoDB table.
  final List<KeySchemaElement>? keySchema;

  /// The shard ID of the item where the operation stopped, inclusive of the
  /// previous result set. Use this value to start a new operation, excluding this
  /// value in the new request.
  ///
  /// If <code>LastEvaluatedShardId</code> is empty, then the "last page" of
  /// results has been processed and there is currently no more data to be
  /// retrieved.
  ///
  /// If <code>LastEvaluatedShardId</code> is not empty, it does not necessarily
  /// mean that there is more data in the result set. The only way to know when
  /// you have reached the end of the result set is when
  /// <code>LastEvaluatedShardId</code> is empty.
  final String? lastEvaluatedShardId;

  /// The shards that comprise the stream.
  final List<Shard>? shards;

  /// The Amazon Resource Name (ARN) for the stream.
  final String? streamArn;

  /// A timestamp, in ISO 8601 format, for this stream.
  ///
  /// Note that <code>LatestStreamLabel</code> is not a unique identifier for the
  /// stream, because it is possible that a stream from another table might have
  /// the same timestamp. However, the combination of the following three elements
  /// is guaranteed to be unique:
  ///
  /// <ul>
  /// <li>
  /// the Amazon Web Services customer ID.
  /// </li>
  /// <li>
  /// the table name
  /// </li>
  /// <li>
  /// the <code>StreamLabel</code>
  /// </li>
  /// </ul>
  final String? streamLabel;

  /// Indicates the current status of the stream:
  ///
  /// <ul>
  /// <li>
  /// <code>ENABLING</code> - Streams is currently being enabled on the DynamoDB
  /// table.
  /// </li>
  /// <li>
  /// <code>ENABLED</code> - the stream is enabled.
  /// </li>
  /// <li>
  /// <code>DISABLING</code> - Streams is currently being disabled on the DynamoDB
  /// table.
  /// </li>
  /// <li>
  /// <code>DISABLED</code> - the stream is disabled.
  /// </li>
  /// </ul>
  final StreamStatus? streamStatus;

  /// Indicates the format of the records within this stream:
  ///
  /// <ul>
  /// <li>
  /// <code>KEYS_ONLY</code> - only the key attributes of items that were modified
  /// in the DynamoDB table.
  /// </li>
  /// <li>
  /// <code>NEW_IMAGE</code> - entire items from the table, as they appeared after
  /// they were modified.
  /// </li>
  /// <li>
  /// <code>OLD_IMAGE</code> - entire items from the table, as they appeared
  /// before they were modified.
  /// </li>
  /// <li>
  /// <code>NEW_AND_OLD_IMAGES</code> - both the new and the old images of the
  /// items from the table.
  /// </li>
  /// </ul>
  final StreamViewType? streamViewType;

  /// The DynamoDB table with which the stream is associated.
  final String? tableName;

  StreamDescription({
    this.creationRequestDateTime,
    this.keySchema,
    this.lastEvaluatedShardId,
    this.shards,
    this.streamArn,
    this.streamLabel,
    this.streamStatus,
    this.streamViewType,
    this.tableName,
  });

  factory StreamDescription.fromJson(Map<String, dynamic> json) {
    return StreamDescription(
      creationRequestDateTime:
          timeStampFromJson(json['CreationRequestDateTime']),
      keySchema: (json['KeySchema'] as List?)
          ?.nonNulls
          .map((e) => KeySchemaElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastEvaluatedShardId: json['LastEvaluatedShardId'] as String?,
      shards: (json['Shards'] as List?)
          ?.nonNulls
          .map((e) => Shard.fromJson(e as Map<String, dynamic>))
          .toList(),
      streamArn: json['StreamArn'] as String?,
      streamLabel: json['StreamLabel'] as String?,
      streamStatus:
          (json['StreamStatus'] as String?)?.let(StreamStatus.fromString),
      streamViewType:
          (json['StreamViewType'] as String?)?.let(StreamViewType.fromString),
      tableName: json['TableName'] as String?,
    );
  }
}

/// A description of a single data modification that was performed on an item in
/// a DynamoDB table.
class StreamRecord {
  /// The approximate date and time when the stream record was created, in <a
  /// href="http://www.epochconverter.com/">UNIX epoch time</a> format and rounded
  /// down to the closest second.
  final DateTime? approximateCreationDateTime;

  /// The primary key attribute(s) for the DynamoDB item that was modified.
  final Map<String, AttributeValue>? keys;

  /// The item in the DynamoDB table as it appeared after it was modified.
  final Map<String, AttributeValue>? newImage;

  /// The item in the DynamoDB table as it appeared before it was modified.
  final Map<String, AttributeValue>? oldImage;

  /// The sequence number of the stream record.
  final String? sequenceNumber;

  /// The size of the stream record, in bytes.
  final int? sizeBytes;

  /// The type of data from the modified DynamoDB item that was captured in this
  /// stream record:
  ///
  /// <ul>
  /// <li>
  /// <code>KEYS_ONLY</code> - only the key attributes of the modified item.
  /// </li>
  /// <li>
  /// <code>NEW_IMAGE</code> - the entire item, as it appeared after it was
  /// modified.
  /// </li>
  /// <li>
  /// <code>OLD_IMAGE</code> - the entire item, as it appeared before it was
  /// modified.
  /// </li>
  /// <li>
  /// <code>NEW_AND_OLD_IMAGES</code> - both the new and the old item images of
  /// the item.
  /// </li>
  /// </ul>
  final StreamViewType? streamViewType;

  StreamRecord({
    this.approximateCreationDateTime,
    this.keys,
    this.newImage,
    this.oldImage,
    this.sequenceNumber,
    this.sizeBytes,
    this.streamViewType,
  });

  factory StreamRecord.fromJson(Map<String, dynamic> json) {
    return StreamRecord(
      approximateCreationDateTime:
          timeStampFromJson(json['ApproximateCreationDateTime']),
      keys: (json['Keys'] as Map<String, dynamic>?)?.map((k, e) =>
          MapEntry(k, AttributeValue.fromJson(e as Map<String, dynamic>))),
      newImage: (json['NewImage'] as Map<String, dynamic>?)?.map((k, e) =>
          MapEntry(k, AttributeValue.fromJson(e as Map<String, dynamic>))),
      oldImage: (json['OldImage'] as Map<String, dynamic>?)?.map((k, e) =>
          MapEntry(k, AttributeValue.fromJson(e as Map<String, dynamic>))),
      sequenceNumber: json['SequenceNumber'] as String?,
      sizeBytes: json['SizeBytes'] as int?,
      streamViewType:
          (json['StreamViewType'] as String?)?.let(StreamViewType.fromString),
    );
  }
}

enum StreamStatus {
  enabling('ENABLING'),
  enabled('ENABLED'),
  disabling('DISABLING'),
  disabled('DISABLED'),
  ;

  final String value;

  const StreamStatus(this.value);

  static StreamStatus fromString(String value) =>
      values.firstWhere((e) => e.value == value,
          orElse: () =>
              throw Exception('$value is not known in enum StreamStatus'));
}

enum StreamViewType {
  newImage('NEW_IMAGE'),
  oldImage('OLD_IMAGE'),
  newAndOldImages('NEW_AND_OLD_IMAGES'),
  keysOnly('KEYS_ONLY'),
  ;

  final String value;

  const StreamViewType(this.value);

  static StreamViewType fromString(String value) =>
      values.firstWhere((e) => e.value == value,
          orElse: () =>
              throw Exception('$value is not known in enum StreamViewType'));
}

class ExpiredIteratorException extends _s.GenericAwsException {
  ExpiredIteratorException({String? type, String? message})
      : super(type: type, code: 'ExpiredIteratorException', message: message);
}

class InternalServerError extends _s.GenericAwsException {
  InternalServerError({String? type, String? message})
      : super(type: type, code: 'InternalServerError', message: message);
}

class LimitExceededException extends _s.GenericAwsException {
  LimitExceededException({String? type, String? message})
      : super(type: type, code: 'LimitExceededException', message: message);
}

class ResourceNotFoundException extends _s.GenericAwsException {
  ResourceNotFoundException({String? type, String? message})
      : super(type: type, code: 'ResourceNotFoundException', message: message);
}

class TrimmedDataAccessException extends _s.GenericAwsException {
  TrimmedDataAccessException({String? type, String? message})
      : super(type: type, code: 'TrimmedDataAccessException', message: message);
}

final _exceptionFns = <String, _s.AwsExceptionFn>{
  'ExpiredIteratorException': (type, message) =>
      ExpiredIteratorException(type: type, message: message),
  'InternalServerError': (type, message) =>
      InternalServerError(type: type, message: message),
  'LimitExceededException': (type, message) =>
      LimitExceededException(type: type, message: message),
  'ResourceNotFoundException': (type, message) =>
      ResourceNotFoundException(type: type, message: message),
  'TrimmedDataAccessException': (type, message) =>
      TrimmedDataAccessException(type: type, message: message),
};