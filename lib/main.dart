import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getGraphqlEndpoint() {
  if (kIsWeb) {
    return 'http://localhost:9000/graphql';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:9000/graphql';
  }

  return 'http://localhost:9000/graphql';
}

final String graphqlEndpoint = getGraphqlEndpoint();

ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink(graphqlEndpoint);
  return ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );
}

const String getAllTodosQuery = r'''
  query GetAllTodos {
    getAllTodos {
      id
      title
      description
      completed
    }
  }
''';

const String createTodoMutation = r'''
mutation CreateTodo($title: String!, $description: String, $completed: Boolean) {
  createTodo(title: $title, description: $description, completed: $completed) {
    id
    title
    description
    completed
  }
}
''';

Future<List<Map<String, dynamic>>> fetchTodos(GraphQLClient client) async {
  final QueryResult result = await client.query(
    QueryOptions(document: gql(getAllTodosQuery)),
  );

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  final todos = result.data?["getAllTodos"] as List<dynamic>;
  return todos.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> createTodo(
  GraphQLClient client, {
  required String title,
  String? description,
  bool completed = false,
}) async {
  final MutationOptions options = MutationOptions(
    document: gql(createTodoMutation),
    variables: {
      'title': title,
      'description': description,
      'completed': completed,
    },
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['createTodo'] as Map<String, dynamic>;
}

void main() async {
  await initHiveForFlutter();
  final clientNotifier = initGraphQLClient();

  runApp(GraphQLProvider(client: clientNotifier, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(getAllTodosQuery)),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) return const CircularProgressIndicator();
        if (result.hasException) return Text(result.exception.toString());

        final todos = (result.data?['getAllTodos'] as List<dynamic>)
            .cast<Map<String, dynamic>>();

        return Scaffold(
          appBar: AppBar(title: const Text('Todos')),
          body: ListView(
            children: todos.map((todo) {
              return ListTile(
                title: Text(todo['title']?.toString() ?? ''),
                subtitle: Text(todo['description']?.toString() ?? ''),
                trailing: Icon(
                  todo['completed'] == true
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
