import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class Talker(Node):
    def __init__(self):
        super().__init__('py_talker')
        self.publisher_ = self.create_publisher(String, 'chatter', 10)
        self.counter = 0
        self.timer = self.create_timer(0.5, self.timer_callback)

    def timer_callback(self):
        msg = String()
        msg.data = f'Hello from py_talker: {self.counter}'
        self.publisher_.publish(msg)
        self.get_logger().info(msg.data)
        self.counter += 1


def main():
    rclpy.init()
    node = Talker()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()

