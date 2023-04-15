// import 'package:graphql/client.dart';
//
// class GraphQl {
//   GraphQLClient createGraphQLClient(
//       {String endPoint, Map<String, String> header}) {
//     final Link _link = HttpLink(
//       endPoint,
//       defaultHeaders: header,
//     );
//
//     return GraphQLClient(
//       cache: GraphQLCache(),
//       link: _link,
//     );
//   }
//
//   Future<QueryResult> graphQLQuery(
//       {String endPoint, String query, Map<String, String> header}) async {
//     final GraphQLClient _client =
//         createGraphQLClient(header: header, endPoint: endPoint);
//
//     final QueryOptions options = QueryOptions(
//       document: gql(query),
//     );
//     final QueryResult result = await _client.query(options);
//     logNesto("GRAPH QL QUERY CALL RESPONSE IS " + result.toString());
//     return result;
//   }
//
//   Future<QueryResult> graphQLMutation(
//       {String endPoint, String query, Map<String, String> header}) async {
//     final GraphQLClient _client =
//         createGraphQLClient(header: header, endPoint: endPoint);
//
//     final MutationOptions options = MutationOptions(
//       document: gql(query),
//     );
//     final QueryResult result = await _client.mutate(options);
//     return result;
//   }
// }
