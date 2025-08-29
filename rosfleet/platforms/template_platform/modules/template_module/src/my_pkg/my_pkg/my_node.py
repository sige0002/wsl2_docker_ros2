import rclpy
from rclpy.node import Node


class ExampleNode(Node):
    def __init__(self) -> None:
        super().__init__('example_node')
        self.declare_parameter('example_param', 42)
        self.declare_parameter('example_text', 'hello')
        value = self.get_parameter('example_param').get_parameter_value().integer_value
        text = self.get_parameter('example_text').get_parameter_value().string_value
        self.get_logger().info(f"example_param={value}, example_text='{text}'")


def main(args=None):
    rclpy.init(args=args)
    node = ExampleNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()

