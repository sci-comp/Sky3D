/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Utility.
°   -----------------------------------------------------
°   Description:
°       Node Extensions.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{
    public static class NodeExtens
    {
        /// <summary> Get or create child node. </summary>
        /// <param name="parent"> Node Parent. </param>
        /// <param name="name"> Node Name. </param>
        /// <param name="show"> Show in the editor. </param>
        public static T GetOrCreate<T>(this Node target, Node parent, 
            String name, bool show = true) where T : Node{
                return GetOrCreate<T>(parent, name, show);
        }

        /// <summary> Get or create child node. </summary>
        /// <param name="name"> Node Name. </param>
        /// <param name="show"> Show in the editor. </param>
        public static T GetOrCreateChild<T>(this Node target, String name, 
            bool show = true) where T : Node{
                return GetOrCreate<T>(target, target, name, show);
        }

        /// <summary> Get or create node. </summary>
        /// <param name="parent"> Parent Node. </param>
        /// <param name="name"> Node Name. </param>
        /// <param name="show"> Show in the editor. </param>
        public static T GetOrCreate<T>(Node parent, String name, bool show = true) where T : Node
        {
            T node = (T)parent.GetNodeOrNull(name);
            if(node == null)
            {
                node        = (T)Activator.CreateInstance(typeof(T));
                node.Name   = name;
                parent.AddChild(node); 
            }
                    
            if(show)
                node.Owner = parent.GetTree().EditedSceneRoot;

            if(node == null)
                throw new Exception("Node is null");
                        
            return node;
        }

        public static void SetNewScale(this MeshInstance target, Vector3 value)
        {
            Transform tmp = target.Transform;
            tmp.basis = new Basis
            {
                x = new Vector3(value.x, 0.0f, 0.0f),
                y = new Vector3(0.0f, value.y, 0.0f),
                z = new Vector3(0.0f, 0.0f, value.z)
            };
            target.Transform = tmp;
            GD.Print(tmp.basis);
        }

        public static void SetPosition(this Spatial target, Vector3 value)
        {
            Transform tmp = target.Transform;
            tmp.origin = value;
            target.Transform = tmp;
        }

    }
}
